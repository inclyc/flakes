{
  ...
}:
{
  imports = [
    ./runners.nix
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "posthog.inclyc.cn" = {
        extraConfig = "reverse_proxy 192.168.31.5:80";
      };
      "staging.inclyc.cn" = {
        serverAliases = [
          "be.staging.inclyc.cn"
          "admin.staging.inclyc.cn"
          "applog.staging.inclyc.cn"
        ];
        extraConfig = "reverse_proxy 192.168.31.7:40000";
      };
      "production.inclyc.cn" = {
        serverAliases = [
          "be.production.inclyc.cn"
          "admin.production.inclyc.cn"
          "applog.production.inclyc.cn"
        ];
        extraConfig = "reverse_proxy 192.168.31.7:40001";
      };
    };
  };
}
