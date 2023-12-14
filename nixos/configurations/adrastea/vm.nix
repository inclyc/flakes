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
  addVFIO = pkgs.writeShellScriptBin "addVFIO" (builtins.readFile ./add-vfio.sh);

  vmDir = "${config.users.users.lyc.home}/VM";
  machineDir = "${vmDir}/machines";

  mkVMCmd =
    { qemu ? pkgs.qemu
    , enableSystemSound ? false
    , enableEmulatedGPU ? false
    , enableGPUPassthrough ? true
    , enableEvdevInputs ? true
    , enableUSB ? true
    , disk ? "data.qcow2"
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
          -device "virtio-vga-gl"
          -display "sdl,gl=on"
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
    pkgs.writeShellScriptBin "vm-launch.sh" ''
      cmd=(
        ${lib.getExe qemu}
        -machine q35
        -accel kvm

        -rtc base=localtime,clock=host
        -smp 16
        -m ${builtins.toString memory}

        -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_synic,hv_vpindex,+invtsc,hv_vapic,-hypervisor

        -serial none

        -drive "if=pflash,format=raw,readonly=on,file=${vmDir}/share/OVMF/OVMF_CODE.fd"
        -drive "if=pflash,format=raw,file=./OVMF_VARS.fd"

        -monitor unix:./monitor.sock,server,nowait


        -device qemu-xhci,id=xhci
        # Logitech, Inc. Webcam C310
        -device usb-host,bus=xhci.0,vendorid=0x046d,productid=0x081b

        ${SystemSound}
        ${EmulatedGPU}
        ${GPUPassthrough}
        ${EvdevInputs}
        ${Network}
        ${disk}
      )

      exec "''${cmd[@]}"
    ''
  ;

  mkVM = { name, cmd }:
    {
      "vm-${name}" = {
        after = [ "add-vfio.service" ];
        requires = [ "add-vfio.service" ];
        serviceConfig = {
          WorkingDirectory = "${machineDir}/${name}";
          User = config.users.users.lyc.name;
          ExecStart = lib.getExe cmd;
          Type = "simple";
          LimitMEMLOCK = "infinity";
          TimeoutStopSec = 15;
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
        ExecStart = "${lib.getExe addVFIO}  0000:01:00.0";
      };
    };
  } // mkVM {
    name = "Elara";
    cmd = mkVMCmd {
      memory = 32 * 1024;
    };
  };


}
