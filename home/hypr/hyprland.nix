{
  inputs,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.plugins = [
    # inputs.hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
  ];
}
