{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ags_1
    # libnotify # config installed
    # gobject-introspection # 通知工具
    # libdbusmenu-gtk3
    # ddcutil
    # libsoup_3
    # gtksourceview
    #
    # # gst
    # gst_all_1.gstreamer
    # gst_all_1.gst-plugins-base
    # gst_all_1.gst-plugins-good
    # gst_all_1.gst-plugins-bad
    # gst_all_1.gst-plugins-ugly
    # gst_all_1.gst-libav
    #
    # # gnome
    # gsettings-desktop-schemas
    # gnome-control-center
    #
    # wrapGAppsHook
  ];

}
