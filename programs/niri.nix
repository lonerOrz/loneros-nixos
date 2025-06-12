{
  pkgs,
  pkgsv3,
  ...
}: {
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # 安装依赖软件
  environment.systemPackages = with pkgs; [
    pkgsv3.wlr-randr
    xwayland-satellite-unstable
    pkgsv3.wayland-utils
    gnome-control-center
  ];
}
