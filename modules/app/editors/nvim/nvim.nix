{ pkgs, lib, config, ... }:
{
  programs.neovim = {
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

  home.packages = with pkgs; [
    rnix-lsp
    sumneko-lua-language-server
    gopls
    pyright
    zk
    rust-analyzer
    clang-tools
    texlab

    stylua
    black
    nixpkgs-fmt
    rustfmt
    nodePackages.prettier

    lldb
  ];
}
