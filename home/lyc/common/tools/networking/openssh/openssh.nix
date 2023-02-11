{ pkgs, lib, config, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      hitmc = {
        hostname = "lan.hitmc.cc";
        user = "lyc";
        port = 25884;
      };
      hitmc-pub = {
        hostname = "t.lyc.cz";
        user = "lyc";
        port = 12742;
      };
      ten = {
        hostname = "t.lyc.cz";
        user = "lyc";
        port = 22;
      };
      portal-llvmws = {
        hostname = "171.214.26.38";
        user = "lyc";
        port = 22;
        localForwards = [{
          bind.port = 8443;
          host.address = "10.20.1.252";
          host.port = 443;
        }];
      };
      metis = {
        hostname = "llvmws.lyc.dev";
        user = "lyc";
        port = 2201;
      };
      adrastea = {
        hostname = "adrastea.lyc.dev";
        user = "lyc";
        port = 22;
      };
    };
  };
}
