{ pkgs, ... }:
let
  display = "wayland";
  winePackages =
    if display == "wayland" then
      [
        pkgs.wine-wayland
        pkgs.wineWow64Packages.waylandFull
      ]
    else
      [
        pkgs.wine
        pkgs.wineWow64Packages.stable
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
