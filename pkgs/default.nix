{ pkgs }:
{
  mpv-handler = pkgs.callPackage ./mpv-handler.nix { };
  shijima-qt = pkgs.callPackage ./shijima-qt.nix { };
  sddm = pkgs.callPackage ./astronaut-sddm.nix {
    theme = "hyprland_kath";
    # themeConfig={
    #   General = {
    #     HeaderText ="Hi";
    #     Background="/home/${username}/Desktop/wp.png";
    #     FontSize="9.0";
    #   };
    # };
  };
  xdman7 = pkgs.callPackage ./xdman7.nix { };
}
