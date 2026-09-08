{
  pkgs,
  username,
  ...
}:

{
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  systemd.services.flatpak-user-update = {
    description = "Update ${username}'s Flatpaks";

    serviceConfig = {
      Type = "oneshot";
      User = username;
      ExecStart = "${pkgs.flatpak}/bin/flatpak --user update --noninteractive";
    };
  };

  systemd.timers.flatpak-user-update = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
