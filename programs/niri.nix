{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # 安装依赖软件
  environment.systemPackages = with pkgs; [
    wlr-randr
    xwayland-satellite-unstable
    wayland-utils
    gnome-control-center
    gammastep # 蓝光过滤
  ];
}
