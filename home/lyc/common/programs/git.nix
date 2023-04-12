{ pkgs, lib, config, ... }:
{
  programs.git = {
    enable = lib.mkDefault true;
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
        smtpuser = config.inclyc.user.email;
        smtpserverport = 465;
        confirm = "always";
      };
    };
  };
}
