final: _prev:
(import ../pkgs { pkgs = final; })
// {
  agent-sandbox = final.callPackage ../pkgs/agent-sandbox {
    agentEnv = final.callPackage ../pkgs/agent-env { };
  };
}
