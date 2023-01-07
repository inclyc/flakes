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
  };


  home.packages = with pkgs; [
    texlab
    tree
    tdesktop
    rnix-lsp
    nixpkgs-fmt
  ];

  home.stateVersion = "22.11";
}
