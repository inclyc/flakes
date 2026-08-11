#!/usr/bin/env python3
import json
import os
import subprocess
import time
from pathlib import Path


RESTART_COOLDOWN_SECONDS = 600
STATE_RECONFIGURED = "reconfigured"
STATE_RESTARTED_PREFIX = "restarted:"


def run_command(command: list[str], *, capture_output: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        check=False,
        text=True,
        capture_output=capture_output,
    )


def is_networkd_active() -> bool:
    return run_command(["systemctl", "--quiet", "is-active", "systemd-networkd.service"]).returncode == 0


def get_link_status() -> dict | None:
    result = run_command(["networkctl", "status", "--json=short", "br0"], capture_output=True)
    if result.returncode != 0:
        return None
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return None


def is_link_healthy(status: dict) -> bool:
    has_dhcpv4_address = any(
        address.get("Family") == 2 and address.get("ConfigSource") == "DHCPv4"
        for address in status.get("Addresses", [])
    )
    has_default_route = any(
        route.get("Family") == 2
        and route.get("DestinationPrefixLength") == 0
        and route.get("TypeString") == "unicast"
        and route.get("GatewayString")
        for route in status.get("Routes", [])
    )
    return (
        status.get("OperationalState") == "routable"
        and status.get("IPv4AddressState") == "routable"
        and has_dhcpv4_address
        and has_default_route
    )


def has_carrier(status: dict) -> bool:
    return "lower-up" in status.get("FlagsString", "").split(",")


def read_state(state_file: Path) -> str:
    try:
        return state_file.read_text().strip()
    except FileNotFoundError:
        return ""


def request_reconfigure(state_file: Path) -> None:
    state_file.write_text(f"{STATE_RECONFIGURED}\n")
    print("br0 lost its DHCPv4 route; requesting reconfiguration", flush=True)
    result = run_command(["networkctl", "reconfigure", "br0"], capture_output=True)
    if result.returncode != 0:
        print("br0 reconfiguration request failed", flush=True)


def restart_networkd(state_file: Path, now: int) -> None:
    state_file.write_text(f"{STATE_RESTARTED_PREFIX}{now}\n")
    print("br0 remains unavailable after reconfiguration; restarting systemd-networkd", flush=True)
    result = run_command(
        ["systemctl", "--no-ask-password", "restart", "systemd-networkd.service"],
        capture_output=True,
    )
    if result.returncode != 0:
        print("systemd-networkd restart request failed", flush=True)


def restart_is_in_cooldown(state: str, now: int) -> bool:
    if not state.startswith(STATE_RESTARTED_PREFIX):
        return False
    try:
        last_restart = int(state.removeprefix(STATE_RESTARTED_PREFIX))
    except ValueError:
        return False
    return now - last_restart < RESTART_COOLDOWN_SECONDS


def main() -> int:
    state_file = Path(os.environ["RUNTIME_DIRECTORY"]) / "state"
    now = int(time.time())

    if not is_networkd_active():
        restart_networkd(state_file, now)
        return 0

    status = get_link_status()
    if status is None:
        return 0

    if is_link_healthy(status):
        state_file.unlink(missing_ok=True)
        return 0

    if not has_carrier(status):
        state_file.unlink(missing_ok=True)
        return 0

    state = read_state(state_file)
    if state == STATE_RECONFIGURED:
        restart_networkd(state_file, now)
    elif restart_is_in_cooldown(state, now):
        return 0
    else:
        request_reconfigure(state_file)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
