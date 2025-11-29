{
  inputs,
  pkgs,
  ...
}:
let
  niri-package = pkgs.callPackage ../pkgs/niri-blur/package.nix { }; # pkgs.nur.repos.lonerOrz.niri-Naxdy; # or pkgs.callPackage ../pkgs/niri-blur/package.nix { }
  niri-blur = niri-package.override {
    withDbus = true;
    withSystemd = true;
    withScreencastSupport = true;
    withDinit = false;
    withNative = true;
    withLto = true;
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
