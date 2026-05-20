{ lib, pkgs, ... }:
{
  imports = [ ./ssh-jump.nix ];

  programs.ssh =
    let
      nc = "${pkgs.libressl.nc}/bin/nc";
      mkProxyCommand = host: port: "${nc} -x ${host}:${toString port} %h %p";
    in
    {
      enable = lib.mkDefault true;
      enableDefaultConfig = false;
      settings = rec {
        "*" = {
          ServerAliveInterval = 3;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "10m";
        };
        hitmc = {
          HostName = "lan.hitmc.cc";
          User = "inclyc";
          Port = 25884;
        };
        hitmc-pub = {
          HostName = "t.inclyc.cn";
          User = "inclyc";
          Port = 12742;
        };
        ten = {
          HostName = "t.inclyc.cn";
          User = "lyc";
          Port = 22;
        };
        metis = {
          HostName = "llvmws.inclyc.cn";
          User = "lyc";
          Port = 20122;
        };
        oparic-base = {
          HostName = "llvmws.inclyc.cn";
          User = "inclyc";
          Port = 20533;
        };
        adrastea = {
          HostName = "100.95.255.126";
          User = "lyc";
          Port = 22;
        };
        adrastea-v6 = adrastea // {
          HostName = "6.adrastea.inclyc.cn";
          Port = 22;
        };
        adrastea-zxy = adrastea // {
          User = "zxy";
        };
        adrastea-zxy-v6 = adrastea-zxy // {
          HostName = "6.adrastea.inclyc.cn";
          Port = 22;
        };
        adrastea-pub = {
          HostName = "t.inclyc.cn";
          User = "lyc";
          Port = 10120;
        };
        metis-win = {
          HostName = "llvmws.inclyc.cn";
          User = "Admininstrator";
          Port = 23101;
        };
        adrastea-win = {
          HostName = "100.124.27.109";
          User = "Administrator";
          Port = 22;
        };
        swyjs = {
          HostName = "40.0.1.110";
          User = "swyjs";
          Port = 22;
        };
        ict-malcon = {
          HostName = "10.3.2.104";
          User = "lyc";
          Port = 22;
        };
        ict-malcon-pub = {
          HostName = "llvmws.inclyc.cn";
          User = "lyc";
          Port = 20179;
        };
        ict-altric = {
          HostName = "10.208.130.147";
          User = "lyc";
          Port = 22;
        };
        ict-repo = {
          HostName = "10.3.2.104";
          User = "lyc";
          Port = 22;
        };
        ict-sw-git = {
          HostName = "10.208.130.239";
          User = "git";
          ProxyCommand = mkProxyCommand "localhost" 9056;
        };
        ict-sw = {
          HostName = "10.208.130.239";
          User = "lyc";
          Port = 22;
        };
        wxiat = {
          HostName = "code.developer.wxiat.com";
          User = "root";
          Port = 22;
          KexAlgorithms = "+diffie-hellman-group1-sha1";
          HostKeyAlgorithms = "+ssh-rsa";
          Ciphers = "+aes128-cbc";
        };
        "8A" = {
          HostName = "192.168.4.172";
          User = "lyc";
          ProxyCommand = mkProxyCommand "localhost" 1080;
        };
        "wxiat-41" = {
          HostName = "192.168.4.41";
          User = "wuzhikun";
          ProxyJump = "8A";
        };
        "ict-44" = {
          HostName = "10.208.130.44";
          User = "i_longyingchi";
        };
        "git-xcoresigma" = {
          HostName = "git.xcoresigma.com";
          User = "git";
          ProxyCommand = mkProxyCommand "localhost" 9056;
        };
        pve = {
          HostName = "llvmws.inclyc.cn";
          User = "root";
          Port = 65500;
        };
        posthog = {
          HostName = "llvmws.inclyc.cn";
          User = "root";
          Port = 20023;
        };
      };
    };
}
