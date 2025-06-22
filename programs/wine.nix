{ pkgs, ... }:
let
  display = "wayland";
  winePackages =
    if display == "wayland" then
      [
        pkgs.wine-wayland
        pkgs.wineWowPackages.waylandFull
      ]
    else
      [
        pkgs.wine
        pkgs.wineWowPackages.stable
      ];
in
{
  environment.systemPackages =
    with pkgs;
    [
      winetricks
    ]
    ++ winePackages;
}
