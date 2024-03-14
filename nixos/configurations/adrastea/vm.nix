/**

  Virtual Machines Configuration

  My virtual machines are hypervised by QEMU, optionally accelarated by KVM.
  The processes are managed by systemd user services, and services declaration are written here.

  Virtual machines are located in $HOME/VM.
  Each virtual machine owns a private directory under "machines".
  Shared data, OVMF binaries, are located at "shared"

  */
{ pkgs, lib, config, ... }:
let
  vmDir = "vm";

  mkVMCmd =
    { qemu ? pkgs.qemu
    , enableSystemSound ? false
    , enableEmulatedGPU ? false
    , enableGPUPassthrough ? true
    , enableEvdevInputs ? true
    , enableUSB ? true
    , memory
    }:
    let
      SystemSound = lib.optionalString enableSystemSound ''
        -audiodev pa,id=snd0
        -device ich9-intel-hda
        -device hda-output,audiodev=snd0
      '';
      EmulatedGPU =
        if enableEmulatedGPU then ''
          -display none
          -vga virtio
          -vnc :0
        '' else ''
          -nographic
          -vga none
        '';
      GPUPassthrough = lib.optionalString enableGPUPassthrough ''
        # VGA compatible controller: NVIDIA Corporation AD102 [GeForce RTX 4090] (rev a1)
        -device vfio-pci,host=01:00.0,x-vga=on
        # Audio device: NVIDIA Corporation AD102 High Definition Audio Controller (rev a1)
        -device vfio-pci,host=01:00.1
      '';
      EvdevInputs = lib.optionalString enableEvdevInputs ''
        -object "input-linux,id=mouse1,evdev=/dev/input/by-id/usb-A4Tech_USB_Mouse-event-mouse"
        -object "input-linux,id=kbd1,evdev=/dev/input/by-id/usb-Milsky_108EC-XRGB_CA2018120001-event-kbd,grab_all=on,repeat=on"
      '';
      Network =
        let
          mkTap = ifname: ''
            -device virtio-net,netdev=net-${ifname}
            -netdev tap,id=net-${ifname},ifname=${ifname},script=no,downscript=no
          '';
        in
        (mkTap "vmtap0")
        + (mkTap "vmtap1");
    in
    pkgs.writeShellScript "vm-launch.sh" ''
      cmd=(
        ${lib.getExe qemu}
        -machine q35
        -accel kvm

        -snapshot

        -rtc base=localtime,clock=host
        -smp 16
        -m ${builtins.toString memory}

        -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_synic,hv_vpindex,+invtsc,hv_vapic,-hypervisor

        -serial none

        -drive "if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
        -drive "if=pflash,format=raw,file=$STATE_DIRECTORY/OVMF_VARS.fd"

        -monitor unix:$RUNTIME_DIRECTORY/monitor.sock,server,nowait


        -device qemu-xhci,id=xhci
        # Logitech, Inc. Webcam C310
        -device usb-host,bus=xhci.0,vendorid=0x046d,productid=0x081b

        ${SystemSound}
        ${EmulatedGPU}
        ${GPUPassthrough}
        ${EvdevInputs}
        ${Network}
        $STATE_DIRECTORY/data.qcow2
      )

      exec "''${cmd[@]}"
    ''
  ;

  mkVM = { name, cmd }:
    let
      directory = "${vmDir}/${name}";
      caps = [ "CAP_NET_ADMIN" ];
    in
    {
      "vm-${name}" = {
        after = [ "add-vfio.service" ];
        requires = [ "add-vfio.service" ];
        serviceConfig = {
          WorkingDirectory = "%S/${directory}";
          StateDirectory = directory;
          RuntimeDirectory = directory;
          User = config.users.users.lyc.name;
          SupplementaryGroups = "wheel";
          ExecStart = cmd;
          Type = "simple";
          LimitMEMLOCK = "infinity";
          TimeoutStopSec = 15;
          AmbientCapabilities = caps;
        };
      };
    };
in
{
  systemd.services = {
    "add-vfio" = {
      path = [ pkgs.pciutils ];
      description = "override devices driver to vfio";

      serviceConfig = rec {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "addVFIO" (builtins.readFile ./add-vfio.sh)}  0000:01:00.0";
      };
    };
  } // mkVM {
    name = "Elara";
    cmd = mkVMCmd {
      memory = 32 * 1024;
      enableEmulatedGPU = true;
    };
  };


}
