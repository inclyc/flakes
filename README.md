<div align="center">
  <h1>Flakes</code></h1>

  <p>
    <strong>New generation dotfiles</strong>
  </p>
</div>

## About

A nix flake that contains my configurations & modules & pkgs.

## Bootstrap

Bootstrap from a flake-disabled nix:
```
nix-shell
```

```
home-manager switch --flake .#configuration
sudo nixos-rebuild switch --flake .#configuration
```

## License

MIT.
