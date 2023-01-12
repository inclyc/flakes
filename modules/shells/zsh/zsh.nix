{ pkgs, lib, config, ... }:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alF";
      update = "sudo nixos-rebuild switch --flake";
      ip = "ip --color=auto";
      grep = "grep --color=auto";
    };

    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    historySubstringSearch.enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    defaultKeymap = "viins";
    completionInit = "autoload -Uz compinit && compinit -iCd ${config.xdg.cacheHome}/zcompdump-$ZSH_VERSION";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";

    zplug = {
      enable = true;
      zplugHome = "${config.xdg.dataHome}/zplug";
      plugins = [
        { name = "hlissner/zsh-autopair"; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
      ];
    };

    initExtra = ''
      source ${./zshrc}
      source ${./p10k.zsh}
    '';

    dirHashes = {
      flakes = "$HOME/workspace/Study/CS/OS/NixOS/flakes";
      llvm = "$HOME/workspace/Study/CS/Compilers/llvm-project";
    };

    sessionVariables = {
      PYTHONHISTFILE = "${config.xdg.dataHome}/python_history";
    };

  };
}
