{ config,
  username,
  host,
  ...
}: let
  inherit (import ../hosts/${host}/variables.nix) autoGarbage;
in{
  programs.nh = {
    enable = true;
    flake = "/home/${username}/NixOS-Hyprland";
    clean.enable = autoGarbage;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };
}
