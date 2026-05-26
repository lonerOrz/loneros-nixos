{
  pkgs,
  ...
}:

{
  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    # wlr.enable = true; # use wlr_git
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr_git # includes RemoteDesktop patch
    ];
    config = {
      # 默认 fallback 配置
      common = {
        default = [
          "gtk"
        ];
      };
      hyprland = {
        default = [
          "hyprland"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      };
      niri = {
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      sway = {
        default = [
          "wlr"
        ];
      };
    };
  };
}
