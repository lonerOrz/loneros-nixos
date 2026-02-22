{
  pkgs,
  host,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) lto native;

  niri = pkgs.nur.repos.lonerOrz.niri-blur.override {
    withDbus = true;
    withSystemd = true;
    withScreencastSupport = true;
    withDinit = false;
    withNative = native;
    withLto = lto;
  };
in
{
  programs.niri = {
    enable = true;
    package = niri;
  };

  environment.systemPackages = with pkgs; [
    wlr-randr
    xwayland-satellite
    wayland-utils
    gammastep # 蓝光过滤
  ];
}
