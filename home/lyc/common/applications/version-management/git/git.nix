{ pkgs, lib, config, ... }:
{
  programs.git = {
    enable = true;
    userName = "Yingchi Long";
    userEmail = "i@lyc.dev";
    signing = {
      key = "296C3FEFEA88ABC5!";
      signByDefault = false;
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.ff = "only";
      push.default = "current";
      rerere.enabled = true;
      sendemail = {
        smtpencryption = "ssl";
        smtpserver = "smtppro.zoho.com.cn";
        smtpuser = "i@lyc.dev";
        smtpserverport = 465;
        confirm = "always";
      };
    };
  };
}
