{
  lib,
  config,
  pkgs,
  ...
}:
let
  name = "caketower";
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
    description = "Minecraft Server (Cake Tower)";
    requires = [ "${serviceName}.socket" ];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = directory;
      WorkingDirectory = "%S/${directory}";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.jdk17}/bin/java"
        "-jar"
        "-Xmx32G"
        "-Xms32G"
        "-javaagent:${config.lib.pkgs.authlib-injector}=https://hitmc.cc/api/yggdrasil"
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
        "-Dusing.aikars.flags=https://mcflags.emc.gs"
        "-Daikars.new.flags=true"
        "server.jar"
        "nogui"
      ];
      ExecStop = "${stopScript} $MAINPID";
      Restart = "always";
      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  systemd.sockets.${serviceName} = {
    description = "Socket for the Minecraft Server (Cake Tower)";
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenFIFO = stdin;
      RemoveOnStop = true;
      FlushPending = true;
    };
  };
}
