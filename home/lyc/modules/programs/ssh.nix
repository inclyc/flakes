{ lib, ... }:
{
  programs.ssh = {
    enable = lib.mkDefault true;
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
    };
  };
}
