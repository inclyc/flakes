{ config, pkgs, ... }:

let
  add-vfio = pkgs.callPackage ./add-vfio { };
  vmDir = "/home/lyc/ict-disks/虚拟机";
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

  sops.secrets."vm-windows/vnc-password" = { };

  systemd.services."vm-windows" = {
    description = "Windows VM Service";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.qemu ];

    serviceConfig = {
      Type = "simple";
      User = "lyc";
      ExecStart = "${pkgs.python3}/bin/python3 ${./vm_windows.py} start";
      ExecStop = "${pkgs.python3}/bin/python3 ${./vm_windows.py} stop";
      WorkingDirectory = vmDir;
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "5min";

      RuntimeDirectory = "vm-windows";
      RuntimeDirectoryMode = "0700";
      LoadCredential = "vnc-password:${config.sops.secrets."vm-windows/vnc-password".path}";

      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "" ];
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [
        "${vmDir}/windows.qcow2"
        "${vmDir}/OVMF_VARS.fd"
      ];
    };
  };
}
