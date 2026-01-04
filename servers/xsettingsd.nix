{
  pkgs,
  ...
}:
{
  systemd.user.services.xsettingsd = {
    description = "XSETTINGS daemon for X11/XWayland clients";

    wantedBy = [ "graphical-session.target" ];
    after = [
      "graphical-session.target"
    ];

    serviceConfig = {
      ExecStart = "${pkgs.xsettingsd}/bin/xsettingsd";
      Restart = "on-failure";
    };
  };
}
