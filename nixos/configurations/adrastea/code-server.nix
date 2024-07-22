{ pkgs, config, ... }:
{
  systemd.user.services."code-server" =
    let
      socketFile = "$XDG_RUNTIME_DIR/code.socket";
      name = "vscode-env";
      fhs = pkgs.buildFHSEnv {
        inherit name;
        targetPkgs =
          pkgs:
          (with pkgs; [
            stdenv.cc
            perl
            python3
            cudatoolkit
            libGL
            glib
            zlib
            git
            openssh
          ])
          ++ [ config.boot.kernelPackages.nvidia_x11 ];
        runScript = pkgs.writeShellScript "code-oss-server.sh" ''
          ${pkgs.code-oss.rehweb}/bin/code-server-oss --host=127.0.0.1 --socket-path "${socketFile}" --without-connection-token
        '';
      };
    in
    {
      description = "Code-OSS remote server";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${fhs}/bin/${name}";
        ExecStop = pkgs.writeShellScript "stop-code-server.sh" ''
          ${pkgs.coreutils}/bin/rm -f "${socketFile}"
        '';
      };
    };
}
