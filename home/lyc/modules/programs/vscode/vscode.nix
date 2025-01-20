{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.vscode = {
    enable = lib.mkDefault false;

    package = pkgs.vscode;
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
          "nix.serverPath" = "nixd";
          "nix.serverSettings" = {
            nixd = {
              formatting.command = [ "nixfmt" ];
            };
          };

          # Remote vscode connections.
          # The configurations is contributed by [this extension](https://github.com/xaberus/vscode-remote-oss)
          "remote.OSS.hosts" = [
            {
              type = "manual";
              name = "adrastea-zxy";
              host = "localhost";
              port = 63301;
              folders = [ ];
            }
            {
              type = "manual";
              name = "local-fhs";
              host = "localhost";
              port = 63300;
              folders = [ ];
            }
          ];

          # Remote SSH platforms.
          "remote.SSH.remotePlatform" = lib.mapAttrs (name: value: "linux") config.programs.ssh.matchBlocks;
        }
      );
  };

  home.packages = with pkgs; [ nixfmt-rfc-style ];
}
