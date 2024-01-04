{ config, pkgs, hostName, rootPath, outputs, lib, ... }:
let
  proxyHost = "127.0.0.1";
  proxyPort = "1081";

  autologin = pkgs.writeShellScript "autologin" ''
    expect_script=/run/topvpn.expect
    cat > "$expect_script" <<EOF
    #!${pkgs.expect}/bin/expect
    spawn ${pkgs.topsap}/bin/topvpn login

    expect "Input your server address(example:192.168.74.12:8112): "
    send "$TOPVPN_SERVER\r"

    expect "Choose the Login_mode: "
    send "1\r"

    expect "User: "
    send "$TOPVPN_USERNAME\r"

    expect "Password: "
    send "$TOPVPN_PASSWORD\r"

    wait
    EOF
    chmod +x "$expect_script"
    exec "$expect_script"
  '';

  entry = pkgs.writeShellScript "entry" ''
    _term() {
      kill -TERM "$__websrv_pid" 2>/dev/null
      exit
    }

    trap _term TERM

    ${pkgs.topsap}/bin/sv_websrv &
    __websrv_pid=$!
    ${socket5} &

    if [ -n "$TOPVPN_SERVER" ]; then
        # wait for sv_websrv starting.
        ${pkgs.coreutils}/bin/sleep 2
        ${autologin} &
    fi

    wait
  '';

  dantd-sample-conf = pkgs.writeText "dantd.sample.conf" (builtins.readFile ./dantd.sample.conf);

  socket5 = pkgs.writeShellScript "socket5" ''
    #!/usr/bin/env bash

    # https://github.com/Hagb/docker-easyconnect/blob/8a1dd3b5644716dd9f664b23fa1bab2e4fcb3555/docker-root/usr/local/bin/start.sh#L34

    cp ${dantd-sample-conf} /run/danted.conf

    internals=""
    externals=""
    for iface in $(ip -o addr | sed -E 's/^[0-9]+: ([^ ]+) .*/\1/' | sort | uniq | grep -v "lo\|sit\|vir"); do
            internals="''${internals}internal: $iface port = 1080\\n"
            externals="''${externals}external: $iface\\n"
    done
    sed /^internal:/c"$internals" -i /run/danted.conf
    sed /^external:/a"$externals" -i /run/danted.conf
    # 在虚拟网络设备 tun0 打开时运行 danted 代理服务器
    [ -n "$NODANTED" ] || (while true
    do
    sleep 3
    [ -d /sys/class/net/tun0 ] && {
    	chmod a+w /tmp
    	${pkgs.dante}/bin/sockd -f /run/danted.conf
    }
    done
    )&
  '';
in
{
  programs.ssh.matchBlocks.swyjs.proxyCommand = "nc -x 127.0.0.1:${proxyPort} %h %p";
  sops.secrets."swyjs-credential" = { };
  sops.defaultSopsFile = rootPath + /secrets/general.yaml;
  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  systemd.user.services.podman-topsap = {
    Unit.After = [ "sops-nix.service" "network.target" ];
    Service =
      let
        podmancli = "${outputs.nixosConfigurations."${hostName}".config.virtualisation.podman.package}/bin/podman";
        podname = "topsap";
        path = lib.makeBinPath (with pkgs; [
          coreutils
          gnused
          gnugrep
          iproute2
          nettools
        ]);
      in
      {
        ExecStartPre = [
          "${podmancli} stop -i ${podname}"
          "${podmancli} rm -i ${podname}"
        ];
        RuntimeDirectory = "podman/${podname}";
        ExecStart = "${podmancli} run"
          + " --rm"
          + " -it"
          + " --privileged" # Allow sv_websrv write MTU.
          + " --device /dev/net/tun"
          + " --cap-add NET_ADMIN"
          + " --sdnotify=conmon"
          + " --name=${podname} "
          + " --log-driver=journald"
          + " -e PATH=${path}"
          + " --env-file=%t/secrets/swyjs-credential"
          + " -p '${proxyHost}:${proxyPort}:1080'"
          + " --tmpfs /tmp"
          + " --tmpfs /var/log"
          + " -v /bin:/bin:ro"
          + " -v /etc/passwd:/etc/passwd"
          + " -v /nix/store:/nix/store:ro"
          + " --rootfs $RUNTIME_DIRECTORY"
          + " ${entry}";
        ExecStop = "${podmancli} stop ${podname}";
        ExecStopPost = "${podmancli} rm -i ${podname}";
        Restart = "always";
        Type = "notify";
        NotifyAccess = "all";
        TimeoutStopSec = 15;
      };
    Install.WantedBy = [ "default.target" ];
  };
}
