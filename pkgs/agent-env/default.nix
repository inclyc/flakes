{
  writeShellScriptBin,
  python3,
  bubblewrap,
}:
writeShellScriptBin "agent-env" ''
  export PATH="${bubblewrap}/bin:$PATH"
  exec ${python3}/bin/python3 ${./agent_env.py} "$@"
''
