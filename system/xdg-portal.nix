{ pkgs, ... }:
{
  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    # wlr.enable = true; # use wlr_git
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr_git # includes RemoteDesktop patch
      # Niri
      xdg-desktop-portal-gnome
    ];
    configPackages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr_git
    ];
    config = {
      # 默认 fallback 配置
      common = {
        default = [
          "gnome"
          "gtk"
        ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
      niri = {
        default = [
          "gnome"
          "wlr"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
      sway = {
        default = [
          "gtk"
          "wlr"
        ];
      };
    };
  };
}
