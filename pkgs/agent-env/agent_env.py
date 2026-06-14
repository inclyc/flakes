#!/usr/bin/env python3
import os
import sys
from pathlib import Path

import tomllib


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


def main():
    cmd = build_bwrap_command()
    try:
        os.execvp("bwrap", cmd)
    except FileNotFoundError:
        sys.exit("bwrap not found, install bubblewrap")
    except Exception as e:
        sys.exit(f"Failed to start: {e}")


if __name__ == "__main__":
    main()
