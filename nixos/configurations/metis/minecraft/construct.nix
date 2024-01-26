{ config, pkgs, ... }:
let
  name = "construct";
  serviceName = "minecraft-${name}";
  directory = "minecraft/${name}";
  stdin = "/run/${directory}/stdin";

  # https://github.com/NixOS/nixpkgs/blob/6e62521155cd3b4cdf6b49ecacf63db2a0cacc73/nixos/modules/services/games/minecraft-server.nix#L25C3-L34C1
  stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
    echo stop > ${stdin}

    # Wait for the PID of the minecraft server to disappear before
    # returning, so systemd doesn't attempt to SIGKILL it.
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';

in
{
  systemd.services.${serviceName} = {
    after = [ "systemd-networkd-wait-online.service" ];
    description = "Minecraft Server (Constructions)";
    requires = [ "${serviceName}.socket" ];
    serviceConfig = rec {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = directory;
      WorkingDirectory = "%S/${directory}";
      ExecStart = "${pkgs.jdk17}/bin/java -Xmx32G -Xms32G -javaagent:${config.lib.pkgs.authlib-injector}=https://hitmc.cc/api/yggdrasil @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.1.30/unix_args.txt nogui";
      ExecStop = "${stopScript} $MAINPID";
      Restart = "always";
      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  systemd.sockets.${serviceName} = {
    description = "Socket for the Minecraft Server (Constructions)";
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenFIFO = stdin;
      RemoveOnStop = true;
      FlushPending = true;
    };
  };
}
