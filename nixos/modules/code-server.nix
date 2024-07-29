{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.inclyc.services."code-server";
in
{
  options.inclyc.services."code-server" = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          exe = lib.mkOption { type = lib.types.str; };
          socketPath = lib.mkOption { type = lib.types.str; };
        };
      }
    );
  };
  config = {
    systemd.user.services = lib.mapAttrs' (n: v: {
      name = "code-server-${n}";
      value = {
        description = "microsoft/vscode remote server";
        # Add NixOS path to systemd service
        path = [ "/run/current-system/sw/" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = pkgs.writeShellScript "start-code-server.sh" ''
            ${lib.concatStringsSep " " [
              v.exe
              "--host=127.0.0.1"
              "--socket-path"
              v.socketPath
              "--without-connection-token"
            ]}
          '';
          ExecStop = pkgs.writeShellScript "stop-code-server.sh" ''
            ${lib.concatStringsSep " " [
              "${pkgs.coreutils}/bin/rm"
              "-f"
              v.socketPath
            ]}
          '';
        };
      };
    }) cfg;
  };
}
