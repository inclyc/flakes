{
  writeTextFile,
  python3,
  bubblewrap,
  systemd,
}:
writeTextFile {
  name = "agent-env";
  destination = "/bin/agent-env";
  executable = true;
  text = ''
    #!${python3}/bin/python3
    import os
    import sys

    os.environ["PATH"] = "${bubblewrap}/bin:${systemd}/bin:" + os.environ.get("PATH", "")
    os.execv("${python3}/bin/python3", ["${python3}/bin/python3", "${./agent_env.py}", *sys.argv[1:]])
  '';
}
