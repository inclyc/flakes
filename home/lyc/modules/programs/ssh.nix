{ lib, pkgs, ... }:
{
  imports = [ ./ssh-jump.nix ];

  programs.ssh =
    let
      nc = "${pkgs.libressl.nc}/bin/nc";
      mkProxyCommand = host: port: "${nc} -x ${host}:${builtins.toString port} %h %p";
    in
    {
      enable = lib.mkDefault true;
      matchBlocks = rec {
        "*" = {
          serverAliveInterval = 3;
          controlMaster = "auto";
          controlPersist = "10m";
        };
        hitmc = {
          hostname = "lan.hitmc.cc";
          user = "inclyc";
          port = 25884;
        };
        hitmc-pub = {
          hostname = "t.inclyc.cn";
          user = "inclyc";
          port = 12742;
        };
        ten = {
          hostname = "t.inclyc.cn";
          user = "lyc";
          port = 22;
        };
        metis = {
          hostname = "llvmws.inclyc.cn";
          user = "lyc";
          port = 20122;
        };
        adrastea = {
          hostname = "100.95.255.126";
          user = "lyc";
          port = 22;
        };
        adrastea-v6 = adrastea // {
          hostname = "6.adrastea.inclyc.cn";
          port = 22;
        };
        adrastea-zxy = adrastea // {
          user = "zxy";
        };
        adrastea-zxy-v6 = adrastea-zxy // {
          hostname = "6.adrastea.inclyc.cn";
          port = 22;
        };
        adrastea-pub = {
          hostname = "t.inclyc.cn";
          user = "lyc";
          port = 10120;
        };
        metis-win = {
          hostname = "llvmws.inclyc.cn";
          user = "Admininstrator";
          port = 23101;
        };
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
          hostname = "llvmws.inclyc.cn";
          user = "lyc";
          port = 20179;
        };
        ict-altric = {
          hostname = "10.3.2.130";
          user = "lyc";
          port = 22;
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
        wxiat = {
          hostname = "code.developer.wxiat.com";
          user = "root";
          port = 22;
          extraOptions = {
            KexAlgorithms = "+diffie-hellman-group1-sha1";
            HostKeyAlgorithms = "+ssh-rsa";
            Ciphers = "+aes128-cbc";
          };
        };
        "8A" = {
          hostname = "192.168.4.172";
          user = "lyc";
          proxyCommand = mkProxyCommand "localhost" 1080;
        };
        "ict-44" = {
          hostname = "10.208.130.44";
          user = "i_longyingchi";
        };
        "git-xcoresigma" = {
          hostname = "git.xcoresigma.com";
          user = "git";
          proxyCommand = mkProxyCommand "localhost" 9056;
        };
        ucas-parallel-course = {
          hostname = "124.16.71.7";
          port = 7882;
          user = "lyc";
        };
        ucas-parallel-course-mpi-node1 = {
          hostname = "124.16.71.70";
          port = 22;
          user = "course";
        };
        ucas-parallel-course-mpi-node2 = {
          hostname = "124.16.71.63";
          port = 22;
          user = "course";
        };
      };
    };
}
