{ config, pkgs, ... }:

let
  add-vfio = pkgs.callPackage ./add-vfio { };
in
{
  imports = [
    ./tap.nix
  ];

  environment.systemPackages = with pkgs; [
    add-vfio

    # RDP client to connect Windows VM, faster than spice.
    freerdp
  ];

  systemd.services."vm-windows" = {
    description = "Windows VM Service";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "lyc";
      ExecStart = "${pkgs.python3}/bin/python3 vm_windows.py ./windows.qcow2";
      WorkingDirectory = "${config.users.users.lyc.home}/ict-disks/虚拟机/";
      Restart = "always";
      RestartSec = 5;
    };
    path = with pkgs; [
      qemu
      python3
    ];
  };
}
