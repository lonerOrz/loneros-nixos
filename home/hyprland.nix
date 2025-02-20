{ inputs
, pkgs
, ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    # enableNvidiaPatches = false;
    systemd.enable = true;
    # withUWSM = true; # One day, but not today
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };
  systemd.user.targets.hyprland-session.Unit.Wants =
    [ "xdg-desktop-autostart.target" ];
}
