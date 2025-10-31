{ ... }:
{
  programs.adb.enable = true;
  users.users.lyc.extraGroups = [ "adbusers" ];
}
