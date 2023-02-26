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
        user = "user";
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
        port = 22;
      };
      adrastea = {
        hostname = "adrastea.lyc.dev";
        user = "lyc";
        port = 22;
      };
      # HPC, 神威.
      swyjs = {
        hostname = "40.0.1.110";
        user = "swyjs";
        port = 22;
      };
      # 计算所组内服务器
      ict-malcon = {
        hostname = "10.3.2.104";
        user = "lyc";
        port = 22;
        proxyCommand = "nc -x localhost:1080 %h %p";
      };
    };
  };
}
