{ ... }:
{
  programs.ssh.matchBlocks = {
    ict-sw.proxyJump = "ict-malcon-pub";
    ict-sw-git.proxyJump = "ict-malcon-pub";
    ict-repo.proxyJump = "ict-malcon-pub";
  };
}
