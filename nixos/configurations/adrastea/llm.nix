{ pkgs, ... }:
let
  llama-cpp = pkgs.llama-cpp.override {
    cudaSupport = true;
  };
in
{
  environment.systemPackages = with pkgs; [
    llama-cpp
    opencode
  ];
}
