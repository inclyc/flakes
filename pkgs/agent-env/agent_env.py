#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
import sys
import tomllib
import uuid
from pathlib import Path

ALLOW_UNSCOPED_ENV = "AGENT_ENV_ALLOW_UNSCOPED"
OOM_SCORE_ADJUST = 500
SLICE_NAME = "agent.slice"
REQUIRED_SLICE_PROPERTIES = (
    "MemoryHigh",
    "MemoryMax",
    "MemorySwapMax",
)
SSH_RUNTIME_DIR = "/run/agent-env-ssh"
SSH_CONFIG_SOURCE = f"{SSH_RUNTIME_DIR}/config"


def expand_path(path_str: str, home: Path, cwd: Path) -> Path:
    """Expand a config path string."""
    if path_str == ".":
        return cwd
    if path_str.startswith("~"):
        return home / path_str[2:]
    return Path(path_str)


def load_config() -> dict:
    """Load config.toml from script directory or XDG_CONFIG_HOME/agent-env/."""
    script_dir = Path(__file__).resolve().parent
    candidates = [
        script_dir / "config.toml",
        Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
        / "agent-env"
        / "config.toml",
    ]
    for config_file in candidates:
        if config_file.is_file():
            with open(config_file, "rb") as f:
                return tomllib.load(f)
    sys.exit("Config not found. Searched:\n" + "\n".join(f"  {p}" for p in candidates))


def get_ssh_bind_specs(ssh_dir: Path) -> list[str]:
    """Build an isolated ~/.ssh mount for the sandbox."""
    mount_args = [
        "--dir",
        SSH_RUNTIME_DIR,
        "--tmpfs",
        str(ssh_dir),
        "--chmod",
        "700",
        str(ssh_dir),
        "--tmpfs",
        "/etc/ssh",
    ]
    for entry in sorted(ssh_dir.iterdir(), key=lambda path: path.name):
        try:
            source = entry.resolve(strict=True)
        except (FileNotFoundError, OSError, RuntimeError):
            continue

        if entry.name == "config":
            if source.is_file():
                mount_args.extend(["--ro-bind", str(source), SSH_CONFIG_SOURCE])
            continue

        if source.is_socket():
            # Existing multiplexing sockets belong to the host and must not
            # cross the sandbox boundary.
            continue

        destination = ssh_dir / entry.name
        if source.is_dir():
            mount_args.extend(
                ["--dir", str(destination), "--ro-bind", str(source), str(destination)]
            )
        elif source.is_file():
            flag = (
                "--bind"
                if entry.name in {"known_hosts", "known_hosts.old"}
                else "--ro-bind"
            )
            mount_args.extend([flag, str(source), str(destination)])

    return mount_args


def get_bind_specs():
    config = load_config()
    home = Path.home()
    cwd = Path.cwd()
    ssh_dir = home / ".ssh"

    ro_binds = []
    ssh_mount_args = []
    for entry in config.get("ro_binds", []):
        path = expand_path(entry, home, cwd)
        if path.exists():
            if path == ssh_dir and path.is_dir():
                ssh_mount_args = get_ssh_bind_specs(path)
                continue
            ro_binds.append(str(path))

    rw_binds = []
    for entry in config.get("rw_binds", []):
        path = expand_path(entry, home, cwd)
        if path.exists():
            if path == ssh_dir and path.is_dir():
                if not ssh_mount_args:
                    ssh_mount_args = get_ssh_bind_specs(path)
                continue
            rw_binds.append(str(path))

    for remap in config.get("rw_remap", []):
        src = expand_path(remap["src"], home, cwd)
        dest = expand_path(remap["dest"], home, cwd)
        if src.exists():
            rw_binds.append((str(src), str(dest)))

    xdg_runtime = os.getenv("XDG_RUNTIME_DIR")
    if xdg_runtime and Path(xdg_runtime).exists():
        rw_binds.append(xdg_runtime)

    ssh_auth_sock = os.getenv("SSH_AUTH_SOCK")
    if ssh_auth_sock and Path(ssh_auth_sock).exists():
        rw_binds.append(ssh_auth_sock)

    return ro_binds, rw_binds, ssh_mount_args


def binds_to_flags(ro_binds, rw_binds):
    """
    Convert declarative bind lists into bwrap command arguments.

    Declarative bind definitions.
    Each entry is either:
      - a string (same source and destination)
      - a tuple (src, dest) for different paths
    """
    args = []

    def add_bind_flags(entry, flag):
        if entry is None:
            return
        elif isinstance(entry, tuple):
            src, dst = entry
            args.extend([flag, str(src), str(dst)])
        else:
            args.extend([flag, str(entry), str(entry)])

    for entry in ro_binds:
        add_bind_flags(entry, "--ro-bind")
    for entry in rw_binds:
        add_bind_flags(entry, "--bind")
    return args


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(add_help=False, allow_abbrev=False)
    parser.add_argument(
        "--ssh-bootstrap",
        dest="ssh_bootstrap",
        nargs=2,
        metavar=("SOURCE", "DESTINATION"),
    )
    parser.add_argument("command", nargs=argparse.REMAINDER)
    return parser.parse_args(argv)


def build_bwrap_command(target_args: list[str]):
    home = Path.home()
    ro_binds, rw_binds, ssh_mount_args = get_bind_specs()
    ssh_auth_sock = os.getenv("SSH_AUTH_SOCK")
    env_args = [
        *("--setenv", "HOME", str(home)),
        *("--setenv", "XDG_CACHE_HOME", str(home / ".cache")),
        *("--setenv", "GIT_SSH_COMMAND", "ssh"),
    ]
    if ssh_auth_sock and Path(ssh_auth_sock).exists():
        env_args.extend(["--setenv", "SSH_AUTH_SOCK", ssh_auth_sock])

    cmd = [
        "bwrap",
        *("--proc", "/proc"),
        *("--dev", "/dev"),
    ]
    cmd.extend(binds_to_flags(ro_binds, rw_binds))
    cmd.extend(ssh_mount_args)

    if ssh_mount_args:
        target_args = [
            sys.executable,
            str(Path(__file__).resolve()),
            "--ssh-bootstrap",
            SSH_CONFIG_SOURCE,
            str(home / ".ssh" / "config"),
            *target_args,
        ]

    cmd.extend(
        [
            "--unshare-ipc",
            "--unshare-pid",
            "--unshare-uts",
            *env_args,
            "--",
            *target_args,
        ]
    )
    return cmd


def bootstrap_ssh_config(source: str, destination: str, target_args: list[str]) -> None:
    """Copy the SSH config into the sandbox and replace this process."""
    if not target_args:
        raise RuntimeError("SSH bootstrap received no target command")

    source_path = Path(source)
    destination_path = Path(destination)
    try:
        if source_path.is_file():
            shutil.copyfile(source_path, destination_path)
        else:
            destination_path.touch()
        destination_path.chmod(0o600)
    except OSError as error:
        raise RuntimeError(f"Unable to prepare sandbox SSH config: {error}") from error

    os.execvp(target_args[0], target_args)


def parse_systemd_properties(output: str) -> dict[str, str]:
    properties = {}
    for line in output.splitlines():
        key, separator, value = line.partition("=")
        if separator:
            properties[key] = value
    return properties


def get_slice_properties() -> dict[str, str]:
    try:
        result = subprocess.run(
            [
                "systemctl",
                "--user",
                "show",
                SLICE_NAME,
                "--property=LoadState",
                *[f"--property={property}" for property in REQUIRED_SLICE_PROPERTIES],
                "--property=ManagedOOMMemoryPressure",
                "--property=ManagedOOMSwap",
            ],
            capture_output=True,
            check=False,
            text=True,
            timeout=5,
        )
    except FileNotFoundError as error:
        raise RuntimeError("systemctl not found") from error
    except subprocess.TimeoutExpired as error:
        raise RuntimeError("Timed out reading agent.slice configuration") from error

    if result.returncode != 0:
        message = result.stderr.strip() or "unknown error"
        raise RuntimeError(f"Unable to read agent.slice configuration: {message}")

    return parse_systemd_properties(result.stdout)


def validate_resource_slice() -> None:
    properties = get_slice_properties()
    if properties.get("LoadState") != "loaded":
        raise RuntimeError("agent.slice is not loaded")

    unlimited = [
        property
        for property in REQUIRED_SLICE_PROPERTIES
        if properties.get(property) in {None, "infinity"}
    ]
    if unlimited:
        raise RuntimeError(
            f"agent.slice has no finite limits for: {', '.join(unlimited)}"
        )

    for property in ("ManagedOOMMemoryPressure", "ManagedOOMSwap"):
        if properties.get(property) != "kill":
            raise RuntimeError(f"agent.slice does not enable {property}=kill")


def set_oom_score_adjust() -> None:
    try:
        Path("/proc/self/oom_score_adj").write_text(f"{OOM_SCORE_ADJUST}\n")
    except OSError as error:
        raise RuntimeError(f"Unable to set oom_score_adj: {error}") from error


def build_scoped_command(bwrap_command: list[str], target_args: list[str]) -> list[str]:
    program_name = Path(target_args[0]).name if target_args else "command"
    scope_name = f"agent-sandbox-{uuid.uuid4()}"
    return [
        "systemd-run",
        "--user",
        "--scope",
        "--quiet",
        "--collect",
        "--same-dir",
        f"--unit={scope_name}",
        f"--description=Constrained agent: {program_name}",
        f"--slice={SLICE_NAME}",
        "--",
        *bwrap_command,
    ]


def main():
    args = parse_args(sys.argv[1:])
    if args.ssh_bootstrap is not None:
        try:
            bootstrap_ssh_config(*args.ssh_bootstrap, args.command)
        except RuntimeError as error:
            sys.exit(str(error))

    cmd = build_bwrap_command(args.command)
    executable = "bwrap"
    if os.environ.get(ALLOW_UNSCOPED_ENV) == "1":
        print(
            f"Warning: {ALLOW_UNSCOPED_ENV}=1 runs the agent without resource limits",
            file=sys.stderr,
        )
    else:
        try:
            validate_resource_slice()
            set_oom_score_adjust()
        except RuntimeError as error:
            sys.exit(
                f"Refusing to start an unbounded agent: {error}\n"
                f"Use {ALLOW_UNSCOPED_ENV}=1 only for emergency bypasses."
            )
        cmd = build_scoped_command(cmd, args.command)
        executable = "systemd-run"

    try:
        os.execvp(executable, cmd)
    except FileNotFoundError:
        sys.exit(f"{executable} not found")
    except OSError as error:
        sys.exit(f"Failed to start: {error}")


if __name__ == "__main__":
    main()
