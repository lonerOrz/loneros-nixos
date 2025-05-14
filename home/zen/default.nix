{
  inputs,
  config,
  pkgs,
  username,
  host,
  system,
  ...
}:

let
  path = "${username}.${host}";

  highlightColor = config.lib.stylix.colors.base0B; # 强调色
  # base06: "#f5e0dc" # rosewater
  # base07: "#b4befe" # lavender
  # base08: "#f38ba8" # red
  # base09: "#fab387" # peach
  # base0A: "#f9e2af" # yellow
  # base0B: "#a6e3a1" # green
  # base0C: "#94e2d5" # teal
  # base0D: "#89b4fa" # blue
  # base0E: "#cba6f7" # mauve
  # base0F: "#f2cdcd" # flamingo

in
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${system}".specific
  ];

  imports = [
    (import ./chrome.nix { inherit path config highlightColor; })
    (import ./content.nix { inherit path config highlightColor; })
    (import ./user.nix { inherit path; })
  ];

  home.file = {
    # profiles.ini 文件
    ".zen/profiles.ini" = {
      text = ''
        [General]
        StartWithLastProfile=1
        Version=2

        [Profile0]
        Name=${username}
        IsRelative=1
        Path=${path}
        ZenAvatarPath=chrome://browser/content/zen-avatars/avatar-53.svg
        Default=1
      '';
    };
  };
}
