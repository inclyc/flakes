{ config, rootPath, ... }:
{
  sops.defaultSopsFile = rootPath + /secrets/general.yaml;
  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
}
