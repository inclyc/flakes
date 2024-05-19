{ pkgs, config, ... }:
{
  programs.vscode.enable = true;

  home.homeDirectory = "/Users/${config.home.username}";

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/flakes";
  };

  inclyc.ssh.ICTProxy = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    (hiPrio clang-tools_16)
    (texlive.combine {
      inherit (texlive) scheme-full;
    })
    clash-meta
    pinentry_mac
    qemu
    telegram-desktop
  ];

  # How about use vscodium for a while?
  # Let's just give it a try then.
  programs.vscode.package = pkgs.vscodium;
  programs.zsh.shellAliases = {
    # Alias the name "code" to codium, for current switching
    code = "codium";
  };

  home.sessionVariables = {
    EDITOR = "codium --wait";
  };

  programs.kitty.enable = true;
  programs.kitty.font = {
    name = "FiraCode Nerd Font Mono";
    size = 13;
  };
}
