{
  pkgs,
  lib,
  config,
  ...
}:
let
  mkUser =
    { user, port }:
    let
      secretName = "code/adrastea/${user}";
    in
    {
      sops.secrets.${secretName} = {
        owner = user;
      };
      systemd.user.services."code-server-fhs-${user}" = {
        description = "Code Server with FHS";
        wantedBy = [ "default.target" ];
        path = [
          "/run/current-system/sw"
          "${config.users.users.${user}.home}/.nix-profile"
        ];

        serviceConfig = {
          ExecStart = "${pkgs.writeScript "start-code-server" ''
            #!${lib.getExe pkgs.linux-fhs-python}
            ${builtins.readFile ./start-code-server.py}
          ''}";
          Environment = [
            "WebHost=${pkgs.vscodium-web-host}"
            "Port=${port}"
            "ConnectionTokenFile=${config.sops.secrets.${secretName}.path}"
          ];
        };
      };

      services.caddy = {
        enable = true;
        virtualHosts = {
          "${user}.adrastea.code.inclyc.cn" = {
            extraConfig = "
          reverse_proxy http://127.0.0.1:${port}
        ";
          };
        };
      };
    };
in
lib.mkMerge [
  (mkUser {
    user = "lyc";
    port = "63300";
  })
  (mkUser {
    user = "zxy";
    port = "63301";
  })
]
