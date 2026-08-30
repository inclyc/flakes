#!/usr/bin/env python3
import os
import socket
import sys
import time


QEMU = "qemu-system-x86_64"
MONITOR_SOCKET = "/run/vm-windows/monitor.sock"


def start() -> None:
    credential_dir = os.environ["CREDENTIALS_DIRECTORY"]
    command = [
        QEMU,
        "-machine",
        "q35",
        "-accel",
        "kvm",
        "-cpu",
        "host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time",
        "-rtc",
        "base=localtime,clock=host",
        "-smp",
        "16",
        "-m",
        "16384",
        "-serial",
        "none",
        "-drive",
        "if=pflash,format=raw,readonly=on,file=./OVMF_CODE.fd",
        "-drive",
        "if=pflash,format=raw,file=./OVMF_VARS.fd",
        "-object",
        f"secret,id=vnc-password,file={credential_dir}/vnc-password",
        "-vnc",
        "0.0.0.0:1,password-secret=vnc-password",
        "-vga",
        "std",
        "-device",
        "qemu-xhci,id=xhci",
        "-device",
        "usb-host,bus=xhci.0,vendorid=0x046d,productid=0x081b",
        "-device",
        "virtio-net,netdev=network0,mac=02:50:F2:00:01:81",
        "-netdev",
        "tap,id=network0,ifname=vmtap0,script=no,downscript=no",
        "-drive",
        "file=./windows.qcow2,format=qcow2",
        "-monitor",
        f"unix:{MONITOR_SOCKET},server=on,wait=off",
        "-sandbox",
        "on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny",
    ]
    os.execvp(command[0], command)


def stop() -> None:
    main_pid = int(os.environ["MAINPID"])
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
            connection.settimeout(5)
            connection.connect(MONITOR_SOCKET)
            connection.sendall(b"system_powerdown\n")
    except OSError as error:
        print(f"Unable to request guest shutdown: {error}", file=sys.stderr, flush=True)

    while True:
        try:
            os.kill(main_pid, 0)
        except ProcessLookupError:
            return
        time.sleep(1)


def main() -> int:
    if sys.argv[1:] == ["start"]:
        start()
        return 0
    if sys.argv[1:] == ["stop"]:
        stop()
        return 0
    print(f"Usage: {sys.argv[0]} start|stop", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
