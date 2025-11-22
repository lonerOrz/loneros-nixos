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
  hypr-command = "${lib.getExe' pkgs.hyprland "Hyprland"}";
  niri-command = "${lib.getExe' niri-blur "niri-session"}";
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
        command = "${niri-command}";
      };
    };
  };

  services.seatd.enable = false; # 会导致黑屏
  users.users.${username}.extraGroups = [ "seat" ];
}
