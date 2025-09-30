{
  pkgs,
  ...
}:
let
  makeWaylandPipewireIdleInhibitService =
    {
      settings,
      idle_inhibitor ? "wayland",
      fileName ? "wayland-pipewire-idle-inhibit.toml",
      systemdTarget ? "graphical-session.target",
    }:

    let
      tomlFormat = pkgs.formats.toml { };
      configFile = tomlFormat.generate fileName (settings // { idle_inhibitor = idle_inhibitor; });
      package = pkgs.wayland-pipewire-idle-inhibit;
    in
    {
      environment.systemPackages = [ package ];

      systemd.user.services.wayland-pipewire-idle-inhibit = {
        description = "Inhibit Wayland idling when media is played through pipewire";
        enable = true;
        serviceConfig = {
          ExecStart = "${package}/bin/wayland-pipewire-idle-inhibit --config ${configFile}";
          Restart = "always";
          RestartSec = 10;
        };
        wantedBy = [ systemdTarget ];
      };
    };
in
# busctl --user call org.wayland.IdleInhibit.Control \
#   /org/wayland/IdleInhibit/Control \
#   org.wayland.IdleInhibit.Control ToggleManual
# 手动切换空闲抑制
makeWaylandPipewireIdleInhibitService {
  settings = {
    verbosity = "WARN";
    media_minimum_duration = 10;
    sink_whitelist = [ ];
    node_blacklist = [
      { app_name = "Chromium"; }
    ];
    idle_inhibitor = "d-bus"; # 可以选择 wayland / d-bus / dry-run
  };
}
