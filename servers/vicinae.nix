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
    };

    wantedBy = [ "default.target" ];
  };
}
