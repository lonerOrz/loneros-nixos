{ pkgs, ... }:
{
  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    # wlr.enable = true; # use wlr_git
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr_git # includes RemoteDesktop patch
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr_git
    ];
    config = {
      # 默认 fallback 配置
      common = {
        default = [ "gtk" ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
      niri = {
        default = [
          "wlr"
          "gtk"
        ];
      };
      sway = {
        default = [
          "wlr"
          "gtk"
        ];
      };
    };
  };
}
