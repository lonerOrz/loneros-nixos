{
  pkgs,
  ...
}:
{
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    dconf # 存储应用程序的设置
    glib # for gsettings to work

    # Qt
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum # kvantum
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum # kvantum
    kdePackages.qtwayland
    gsettings-qt # 访问和修改应用程序设置的工具

    # GTK
    nwg-look # GTK主题管理工具
    gsettings-desktop-schemas
    xsettingsd # gtk 守护进程
    gtk-engine-murrine # GTK+ 2.x 的一个 主题引擎

    # theme
    adwaita-icon-theme
    material-symbols
    adw-gtk3
    morewaita-icon-theme
  ];

  # https://discourse.nixos.org/t/how-is-xdg-data-dirs-set-for-some-apps/38432
  environment.sessionVariables = {
    GSETTINGS_SCHEMAS_PATH = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}";
  };
  environment.pathsToLink = [ "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas" ];
}
