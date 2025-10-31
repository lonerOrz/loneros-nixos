{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    gnome-system-monitor # GNOME 风格监视器
    gnome-calendar
    gnome-control-center
  ];
}
