{
  pkgs,
  lib,
  config,
  ...
}:
let
  mkUser =
    user:
    let
      secretName = "code/adrastea/${user}";
      port =
        {
          "lyc" = "63300";
          "zxy" = "63301";
        }
        .${user};
    in
    {
      sops.secrets.${secretName} = {
        owner = user;
      };
      systemd.user.services."code-server-fhs-${user}" = {
        description = "Code Server with FHS";
        wantedBy = [ "multi-user.target" ];

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
  (mkUser "lyc")
  (mkUser "zxy")
]
