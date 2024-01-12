{ lib, ... }:
{
  programs.ssh = {
    enable = lib.mkDefault true;
    matchBlocks = {
      hitmc = {
        hostname = "lan.hitmc.cc";
        user = "inclyc";
        port = 25884;
      };
      hitmc-pub = {
        hostname = "t.lyc.dev";
        user = "inclyc";
        port = 12742;
      };
      ten = {
        hostname = "t.lyc.dev";
        user = "lyc";
        port = 22;
      };
      metis = {
        hostname = "llvmws.lyc.dev";
        user = "lyc";
        port = 20122;
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
        proxyCommand = "nc -x 127.0.0.1:1081 %h %p";
      };
      ict-malcon = {
        hostname = "10.3.2.104";
        user = "lyc";
        port = 22;
      };
      ict-repo = {
        hostname = "10.3.2.104";
        user = "lyc";
        port = 22;
      };
      ict-sw = {
        hostname = "10.208.130.239";
        user = "lyc";
        port = 22;
      };
    };
  };
}
