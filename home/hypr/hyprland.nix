{
  inputs,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.plugins = [
    inputs.hyprspace.packages.${pkgs.system}.Hyprspace
  ];
}
