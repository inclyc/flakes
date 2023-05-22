{ config
, lib
, pkgs
, ...
}:
with lib;
let
  cfg = config.inclyc.user;
in
{
  options.inclyc.user = {
    enable = mkEnableOption "enable user 'lyc' (myself)";
    ssh = mkOption {
      type = types.bool;
      default = true;
    };
    zsh = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      users.users.lyc = {
        isNormalUser = true;
        description = "Yingchi Long";
        extraGroups = [ "wheel" ];
        initialHashedPassword = "$6$FxHqtS36/M3iEKU4$VwEHfgZPtcwlnLjC9DE33u5Shmcd77XwEWryIHBBhRgTDL7Pa536wUBiEKlaDldCMBPBOCSNLz9ObEADwP0O20";
      };
    }
    (mkIf config.networking.networkmanager.enable {
      users.users.lyc.extraGroups = [ "networkmanager" ];
    })
    (mkIf cfg.ssh {
      users.users.lyc.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEleFfCz0snjc4Leoi8Ad2KQykTopiJBy/ratqww7xhE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOY+bJyD0pMB2YT+PU6bb9AkZJNeTckWrmewcgoWhPGL"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3qIMkf0S9qfGN0c/ZsFeEqA2Q6ebdjrZMjGKcfPPdl"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOaTuhZmnqapIx6oMW1I0TCeocVAEhmNXELbIKmazdVR"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6ezp2umiMwAo2+bOsdQnTRs+0Suv9b+hF63h/XPYZv"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkYzGkwtGiync8npD5qTPT7fbgviw8dOL5LsrVpAMy3"
      ];
    })
    (mkIf cfg.zsh {
      users.users.lyc.shell = pkgs.zsh;
      programs.zsh.enable = true;
    })
  ]);
}
