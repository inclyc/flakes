{ pkgs, lib, ... }:
{
  programs.vscode = {
    enable = lib.mkDefault false;

    # Use open-source version of microsoft/vscode
    package = pkgs.vscodium;
    userSettings =
      (builtins.fromJSON (builtins.readFile ./settings.json))
      // (
        let
          nvimPath = "${pkgs.neovim}/bin/nvim";
          zshPath = "${pkgs.zsh}/bin/zsh";
        in
        {
          # path.linux may specified "incorrectly" on darwin
          # because it will link to *darwin* executable. This configuration
          # should be evaulated on corresponding platform, and chosed by vscode.
          "vscode-neovim.neovimExecutablePaths.linux" = nvimPath;
          "vscode-neovim.neovimExecutablePaths.darwin" = nvimPath;

          "terminal.integrated.profiles.osx".zsh.path = zshPath;
          "terminal.integrated.profiles.linux".zsh.path = zshPath;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${lib.getExe pkgs.nixd}";
          "nix.serverSettings" = {
            nixd = {
              formatting.command = [ "nixfmt" ];
            };
          };
        }
      );
  };

  home.packages = with pkgs; [ nixfmt-rfc-style ];
}
