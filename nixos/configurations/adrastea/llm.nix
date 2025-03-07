{ ... }:
let
  port = 11234;
in
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  services.open-webui = {
    inherit port;
    enable = true;
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "ai.inclyc.cn" = {
        extraConfig = "
          reverse_proxy http://127.0.0.1:${builtins.toString port}
        ";
      };
    };
  };
}
