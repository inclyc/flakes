{ hostName, outputs, ... }:
let
  proxyHost = "127.0.0.1";
  proxyPort = "1081";
in
{
  programs.ssh.matchBlocks.swyjs.proxyCommand = "nc -x 127.0.0.1:${proxyPort} %h %p";
  sops.secrets."swyjs-credential" = { };
  systemd.user.services.podman-topsap = {
    Unit = { };
    Service =
      let
        podmancli = "${outputs.nixosConfigurations."${hostName}".config.virtualisation.podman.package}/bin/podman";
        podname = "topsap";
      in
      {
        ExecStartPre = [
          "${podmancli} stop -i ${podname}"
          "${podmancli} rm -i ${podname}"
        ];
        ExecStart = "${podmancli} run"
          + " --rm"
          + " --privileged"
          + " --device /dev/net/tun"
          + " --cap-add NET_ADMIN"
          + " --sdnotify=conmon"
          + " --name=${podname} "
          + " --log-driver=journald"
          + " --env-file=/run/user/1000/secrets/swyjs-credential"
          + " -p '${proxyHost}:${proxyPort}:1080'"
          + " ghcr.io/inclyc/containerized-topsap:main";
        ExecStop = "${podmancli} stop ${podname}";
        ExecStopPost = "${podmancli} rm -i ${podname}";
        Restart = "always";
        Type = "notify";
        NotifyAccess = "all";
        TimeoutStopSec = 15;
        After = [ "sops-nix.service" ];
      };
  };
}
