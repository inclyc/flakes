{ config, ... }:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alFh";
      update = "home-manager switch --flake . && sudo nixos-rebuild switch --flake .";
      ip = "ip --color=auto";
      grep = "grep --color=auto";
    };

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    historySubstringSearch.enable = true;
    autocd = true;
    dotDir = "${config.xdg.configHome}/zsh";
    completionInit = "autoload -Uz compinit && compinit -iCd ${config.xdg.cacheHome}/zcompdump-$ZSH_VERSION";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";

    zplug = {
      enable = true;
      zplugHome = "${config.xdg.dataHome}/zplug";
      plugins = [
        { name = "hlissner/zsh-autopair"; }
      ];
    };

    initContent = ''
      source ${./zshrc}
    '';
  };
}
