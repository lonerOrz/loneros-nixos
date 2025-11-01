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
  ];
}
