{ config, hostName, outputs, ... }:
let
  proxyHost = "127.0.0.1";
  proxyPort = "1080";
  podname = "easyconnect";
  podman = "${outputs.nixosConfigurations."${hostName}".config.virtualisation.podman.package}/bin/podman";
in
{
  programs.ssh.matchBlocks.ict-malcon.proxyCommand = "nc -x 127.0.0.1:${proxyPort} %h %p";
  programs.ssh.matchBlocks.ict-repo.proxyCommand = "nc -x 127.0.0.1:${proxyPort} %h %p";
  systemd.user.services."podman-${podname}" = {
    Unit = { };
    Service = {
      ExecStartPre = [
        "${podman} stop -i ${podname}"
        "${podman} rm -i ${podname}"
      ];
      ExecStart = "${podman} run"
        + " --rm"
        + " --sdnotify=conmon"
        + " --name=${podname} "
        + " --log-driver=journald"
        + " -v ${config.xdg.dataHome}/Easyconnect:/root"
        + " -e PASSWORD=xxxx"
        + " -p 127.0.0.1:5901:5901"
        + " -p '${proxyHost}:${proxyPort}:1080'"
        + " --device /dev/net/tun"
        + " --cap-add NET_ADMIN"
        + " hagb/docker-easyconnect:7.6.3";
      ExecStop = "${podman} stop ${podname}";
      ExecStopPost = "${podman} rm -i ${podname}";
      Restart = "always";
      Type = "notify";
      NotifyAccess = "all";
      TimeoutStopSec = 15;
      After = [ "network.target" ];
    };
    Install.WantedBy = [ "default.target" ];
  };
}
