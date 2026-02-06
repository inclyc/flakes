{ ... }:
let
  port = 9134;
in
{
  services.headscale = {
    enable = true;
    inherit port;
    address = "127.0.0.1";
    settings = {
      server_url = "https://hs.inclyc.cn";
      dns = {
        magic_dns = false;
        override_local_dns = false;
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "hs.inclyc.cn".extraConfig = ''
        reverse_proxy localhost:${toString port}
      '';
    };
  };
}
