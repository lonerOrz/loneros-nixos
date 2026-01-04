{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.session.idle.hypridle;

  hypridleConfig = pkgs.writeText "hypridle.conf" cfg.configText;
in
{
  options.session.idle.hypridle = {
    enable = lib.mkEnableOption "hypridle idle daemon";

    configText = lib.mkOption {
      type = lib.types.lines;
      description = "hypridle configuration (immutable, Nix-managed)";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.hypridle = {
      description = "Hypridle idle management daemon";

      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle -c ${hypridleConfig}";
        Restart = "on-failure";
      };
    };
  };
}
