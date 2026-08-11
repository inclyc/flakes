#!/usr/bin/env python3
import os
import subprocess
import sys
import uuid
from pathlib import Path

import tomllib


ALLOW_UNSCOPED_ENV = "AGENT_ENV_ALLOW_UNSCOPED"
OOM_SCORE_ADJUST = 500
SLICE_NAME = "agent.slice"
REQUIRED_SLICE_PROPERTIES = (
    "MemoryHigh",
    "MemoryMax",
    "MemorySwapMax",
)


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
        Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "agent-env" / "config.toml",
    ]
    for config_file in candidates:
        if config_file.is_file():
            with open(config_file, "rb") as f:
                return tomllib.load(f)
    sys.exit("Config not found. Searched:\n" + "\n".join(f"  {p}" for p in candidates))


def get_bind_specs():
    config = load_config()
    home = Path.home()
    cwd = Path.cwd()

    ro_binds = []
    for entry in config.get("ro_binds", []):
        path = expand_path(entry, home, cwd)
        if path.exists():
            ro_binds.append(str(path))

    rw_binds = []
    for entry in config.get("rw_binds", []):
        path = expand_path(entry, home, cwd)
        if path.exists():
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

    return ro_binds, rw_binds

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


def build_bwrap_command():
    home = Path.home()
    ro_binds, rw_binds = get_bind_specs()
    ssh_auth_sock = os.getenv("SSH_AUTH_SOCK")
    env_args = [
        *("--setenv", "HOME", str(home)),
        *("--setenv", "GIT_SSH_COMMAND", "ssh -F /dev/null"),
        *("--setenv", "XDG_CACHE_HOME", str(home / ".cache")),
    ]
    if ssh_auth_sock and Path(ssh_auth_sock).exists():
        env_args.extend(["--setenv", "SSH_AUTH_SOCK", ssh_auth_sock])

    cmd = [
        "bwrap",
        *("--proc", "/proc"),
        *("--dev", "/dev"),
    ]
    cmd.extend(binds_to_flags(ro_binds, rw_binds))
    args = sys.argv[1:]

    cmd.extend(
        [
            "--unshare-ipc",
            "--unshare-pid",
            "--unshare-uts",
            *env_args,
            "--",
            *args,
        ]
    )
    return cmd


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
        raise RuntimeError(f"agent.slice has no finite limits for: {', '.join(unlimited)}")

    for property in ("ManagedOOMMemoryPressure", "ManagedOOMSwap"):
        if properties.get(property) != "kill":
            raise RuntimeError(f"agent.slice does not enable {property}=kill")


def set_oom_score_adjust() -> None:
    try:
        Path("/proc/self/oom_score_adj").write_text(f"{OOM_SCORE_ADJUST}\n")
    except OSError as error:
        raise RuntimeError(f"Unable to set oom_score_adj: {error}") from error


def build_scoped_command(bwrap_command: list[str]) -> list[str]:
    args = sys.argv[1:]
    program_name = Path(args[0]).name if args else "command"
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
    cmd = build_bwrap_command()
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
        cmd = build_scoped_command(cmd)
        executable = "systemd-run"

    try:
        os.execvp(executable, cmd)
    except FileNotFoundError:
        sys.exit(f"{executable} not found")
    except Exception as e:
        sys.exit(f"Failed to start: {e}")


if __name__ == "__main__":
    main()
