{
  pkgs,
  ...
}:
let
  vicinaePkg = pkgs.callPackage ../pkgs/vicinae/package.nix { };
in
{
  environment.systemPackages = [
    vicinaePkg
  ];

  systemd.user.services.vicinaed = {
    description = "Vicinae server daemon";
    documentation = [ "https://docs.vicinae.com" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    bindsTo = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${vicinaePkg}/bin/vicinae server";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      KillMode = "process";

      Environment = ''
        PATH=$HOME/.nix-profile/bin:/run/current-system/sw/bin:/usr/bin
        DISPLAY=:0
        XDG_RUNTIME_DIR=/run/user/1000
        WAYLAND_DISPLAY=wayland-1
        DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
      '';
    };

    wantedBy = [ "default.target" ];
  };
}
