{ pkgs, lib, config, ... }:
{
  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        everforest
        luasnip
        vim-lastplace
        editorconfig-nvim
        lualine-nvim
        which-key-nvim
        lualine-lsp-progress
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            tree-sitter-nix
            tree-sitter-lua
            tree-sitter-rust
            tree-sitter-go
          ]
        ))
      ];

      extraConfig = ''
        set viminfo+=n${config.xdg.stateHome}/viminfo
        let g:everforest_background = 'soft'
        colorscheme everforest
        luafile ${./nvim.lua}
      '';
    };

    vscode = {
      enable = true;
      userSettings = {
        "files.autoSave" = "onFocusChange";
        "editor.lineNumbers" = "relative";
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "nix.serverPath" = "rnix-lsp";
        "nix.enableLanguageServer" = true;
        "workbench.colorTheme" = "Nord";
        "editor.formatOnSave" = true;
        "editor.formatOnSaveMode" = "modifications";

        "[nix]" = {
          "editor.tabSize" = 2;
        };
      };
      extensions = with pkgs.vscode-extensions; [
        vadimcn.vscode-lldb
        llvm-vs-code-extensions.vscode-clangd
        jnoortheen.nix-ide
        eamodio.gitlens
        mhutchie.git-graph
        asvetliakov.vscode-neovim
        arcticicestudio.nord-visual-studio-code
        usernamehw.errorlens
        james-yu.latex-workshop
        shardulm94.trailing-spaces
      ];
    };

    zsh = {
      enable = true;
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -l";
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
    };

    gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };

    git = {
      enable = true;
      userName = "Yingchi Long";
      userEmail = "i@lyc.dev";
      signing = {
        key = "296C3FEFEA88ABC5!";
        signByDefault = true;
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
  };


  home.packages = with pkgs; [
    texlab
    tree
    tdesktop
    rnix-lsp
    nixpkgs-fmt
    firefox
    kate
    thunderbird
  ];

  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    '';
  };

  xdg.enable = true;

  home.stateVersion = "22.11";
}
