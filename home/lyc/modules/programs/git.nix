{ lib, ... }:
{
  programs.git = {
    enable = lib.mkDefault true;
    signing = {
      key = "296C3FEFEA88ABC5!";
      signByDefault = true;
      format = "openpgp";
    };
    ignores = [
      ".DS_Store"
      ".direnv"
      ".claude/settings.local.json"
      ".pnpm-store"
      "__pycache__/"
    ];
    settings = {
      core.quotepath = false;
      init.defaultBranch = "main";
      pull.ff = "only";
      push.default = "current";
      push.autoSetupRemote = true;
      rebase.autosquash = true;
      rebase.autoStash = true;
      rerere.enabled = true;
    };
  };
}
