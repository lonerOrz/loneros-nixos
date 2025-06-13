{ pkgs, ... }:
{
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # 安装依赖软件
  environment.systemPackages = with pkgs; [
    wlr-randr
    xwayland-satellite-unstable
    wayland-utils
    gnome-control-center
  ];
}
