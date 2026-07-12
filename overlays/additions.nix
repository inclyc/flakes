final: _prev:
(import ../pkgs { pkgs = final; })
// {
  agent-env = final.callPackage ../pkgs/agent-env { };
  agent-sandbox = final.callPackage ../pkgs/agent-sandbox {
    agentEnv = final.agent-env;
  };
}
