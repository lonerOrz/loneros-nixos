{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    atuin # shell history manager
  ];

  systemd.user.services.atuin-sync = {
    description = "Atuin auto sync";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.atuin}/bin/atuin sync";
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.atuin-sync = {
    description = "Atuin auto sync";
    timerConfig = {
      OnUnitActiveSec = "1h";
      OnBootSec = "5min";
      Unit = "atuin-sync.service";
      Persistent = true; # 如果错过启动，补触发
    };
    wantedBy = [ "default.target" ];
    upheldBy = [ "default.target" ];
  };
}
