{ lib, config, ... }:
let
  providers = [ "dler" "mielink" "bywave" ];

  mkProvider = name: {
    type = "http";
    path = "./${name}.yaml";
    url = "${config.sops.placeholder."clash-provider/${name}"}";
    interval = 3600;
    health-check = {
      enable = true;
      url = "http://www.gstatic.com/generate_204";
      interval = 300;
    };
  };
  mkSecret = name: {
    "clash-provider/${name}" = { };
  };

  proxyProviders = lib.genAttrs providers mkProvider;

  proxyGroups = [
    {
      name = "Proxy";
      type = "select";
      use = providers;
      proxies = [
        "Auto"
        "DIRECT"
      ];
    }
    {
      name = "Auto";
      type = "url-test";
      use = providers;
      proxies = [ "DIRECT" ];
      url = "http://cp.cloudflare.com/generate_204";
      interval = "3600";
    }
  ] ++ builtins.fromJSON (builtins.readFile ./proxy-groups.json);
in
{
  sops.secrets = lib.attrsets.mergeAttrsList (map mkSecret providers);
  sops.templates."clash-config.yaml".content = builtins.readFile ./rule.yaml + ''
    proxy-groups: ${builtins.toJSON proxyGroups}
    proxy-providers: ${builtins.toJSON proxyProviders}
  '';

  sops.templates."clash-config.yaml".owner = config.services.clash.user;
}
