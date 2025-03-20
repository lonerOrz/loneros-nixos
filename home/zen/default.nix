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
  path = "${host}.${username}";
in
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${system}".specific
  ];

  imports = [
    (import ./chrome.nix { inherit path config; })
    (import ./content.nix { inherit path config; })
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
