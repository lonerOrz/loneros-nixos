{
  inputs,
  pkgs,
  ...
}:
let
  niri-blur = (pkgs.callPackage ../pkgs/niri-blur/package.nix { }).override {
    withDbus = true;
    withSystemd = true;
    withScreencastSupport = true;
    withDinit = false;
  };
in
{
  programs.niri = {
    enable = true;
    package = niri-blur;
  };

  # 安装依赖软件
  environment.systemPackages = with pkgs; [
    wlr-randr
    xwayland-satellite
    wayland-utils
    gammastep # 蓝光过滤
  ];
}
