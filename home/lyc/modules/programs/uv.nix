{ pkgs, ... }:
let
  fmt = pkgs.formats.toml { };
in
{
  xdg.configFile."uv/uv.toml".source = fmt.generate "uv.toml" {
    # Fields reference: https://docs.astral.sh/uv/reference/settings
    python-downloads = "manual";
    python-preference = "managed";
    index = [
      {
        url = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple";
        default = true;
      }
    ];
  };
}
