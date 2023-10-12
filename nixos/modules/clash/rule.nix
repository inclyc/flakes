{ config, ... }:

{
  sops.secrets."clash-provider" = { };

  sops.templates."clash-config.yaml".content = builtins.readFile ./rule.yaml + ''
    proxy-providers:
     dlercloud:
       type: http
       path: ./dlercloud.yaml
       url: "${config.sops.placeholder."clash-provider"}"
       interval: 3600
       health-check:
         enable: true
         url: http://www.gstatic.com/generate_204
         interval: 300
  '';

  sops.templates."clash-config.yaml".owner = config.services.clash.user;
}
