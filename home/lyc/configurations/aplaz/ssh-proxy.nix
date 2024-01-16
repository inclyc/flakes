{ ... }:
let
  metisProxyICT = "llvmws.lyc.dev:20179";
  metisProxySW = "llvmws.lyc.dev:20178";
  proxyCommandSW = "nc -x ${metisProxySW} %h %p";
  proxyCommandICT = "nc -x ${metisProxyICT} %h %p";
in
{
  programs.ssh.matchBlocks = {
    ict-malcon.proxyCommand = proxyCommandICT;
    ict-sw.proxyCommand = proxyCommandICT;
    ict-repo.proxyCommand = proxyCommandICT;
    swyjs.proxyCommand = proxyCommandSW;
  };
}
