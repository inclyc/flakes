{ lib, ... }:
{
  programs.ssh = {
    enable = lib.mkDefault true;
    serverAliveInterval = 3;
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
        hostname = "10.231.0.2";
        user = "lyc";
        port = 22;
      };
      adrastea-pub = {
        hostname = "t.lyc.dev";
        user = "lyc";
        port = 10120;
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
      ict-malcon-pub = {
        hostname = "101.43.242.13";
        user = "lyc";
        port = 10179;
      };
      ict-repo = {
        hostname = "10.3.2.104";
        user = "lyc";
        port = 22;
      };
      ict-sw-git = {
        hostname = "10.208.130.239";
        user = "git";
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
