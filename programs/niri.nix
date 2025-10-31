{
  inputs,
  pkgs,
  ...
}:
let
  niri-blur = (pkgs.callPackage ../pkgs/niri-blur/package.nix { }).override { withDinit = true; };
in
{
  imports = [ inputs.niri.nixosModules.niri ];

  niri-flake.cache.enable = true;

  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri = {
    enable = true;
    package = niri-blur;
  };

  # 安装依赖软件
  environment.systemPackages = with pkgs; [
    wlr-randr
    xwayland-satellite-unstable
    wayland-utils
    gammastep # 蓝光过滤
  ];
}
