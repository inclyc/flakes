/**
  Disable "bad permission" checking in openssh.
*/
final: prev: {
  openssh = prev.openssh.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./no-check-permission.patch ];
    doCheck = false;
  });
}
