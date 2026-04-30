{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "zju-connect";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "ZJU-Connect";
    rev = "v${version}";
    hash = "sha256-JS0C8j5tAYTrOa7ZYxnq9vSqHJk/YZO/qPX5E+cFhVc=";
  };

  vendorHash = "sha256-H+WtDkq8FckXuriEQNh1vhsGIkw1U7RlhQeAbO0jUXQ=";

  meta = {
    description = "ZJU RVPN 客户端的 Go 语言实现";
    homepage = "https://github.com/Mythologyli/ZJU-Connect";
    mainProgram = "zju-connect";
    license = lib.licenses.agpl3Only;
  };
}
