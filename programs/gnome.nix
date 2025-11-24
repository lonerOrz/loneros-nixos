{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    gnome-system-monitor # GNOME 风格监视器
    gnome-control-center

    gnome-calendar
    evolution-data-server # Unified backend
    libical # for calendar support

    file-roller # GNOME 风格的归档管理器
    eog # GNOME 桌面环境中的一个图像查看器
    baobab # GNOME 桌面环境的一个磁盘使用情况分析工具
  ];

  programs.seahorse.enable = true; # GNOME 密钥管理器
}
