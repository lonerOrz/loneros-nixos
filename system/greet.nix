{
  lib,
  pkgs,
  username,
  ...
}:
let
  niri-blur = (pkgs.callPackage ../pkgs/niri-blur/package.nix { }).override {
    withDbus = true;
    withSystemd = true;
    withScreencastSupport = true;
    withDinit = false;
  };
  hypr-session = "${pkgs.hyprland}/bin/Hyprland";
  niri-session = "${lib.getExe' niri-blur "niri-session"} -l";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "${username}";
        command = "${pkgs.tuigreet}/bin/tuigreet -g 'Welcome to the loneros!' --user-menu --time --time-format '%A, %B %d, %Y - %I:%M:%S %p' --asterisks --greet-align center --theme border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red"; # start Hyprland with a TUI login manager
      };
      # 自动登录: --cmd ${session}
      initial_session = {
        user = "${username}";
        command = "${niri-session}";
      };
    };
  };
}
