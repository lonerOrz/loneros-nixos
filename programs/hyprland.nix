{
  inputs,
  host,
  pkgs,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) lto native;
  system = pkgs.stdenv.hostPlatform.system;
  hyprland-git = inputs.hyprland.packages.${system}.hyprland.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.cmake ];

    cmakeFlags =
      (old.cmakeFlags or [ ])
      ++ [ "-DCMAKE_BUILD_TYPE=RelWithDebInfo" ]
      ++ pkgs.lib.optional lto "-DENABLE_LTO=ON";

    NIX_CFLAGS_COMPILE =
      (old.NIX_CFLAGS_COMPILE or "") + pkgs.lib.optionalString native " -march=native" + " -O3";
    NIX_CXXFLAGS_COMPILE =
      (old.NIX_CXXFLAGS_COMPILE or "") + pkgs.lib.optionalString native " -march=native" + " -O3";
  });
  hyprland-portal-git = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
in
{
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland; # hyprland-git or pkgs.hyprland
    portalPackage = pkgs.xdg-desktop-portal-hyprland; # hyprland-portal-git or pkgs.xdg-desktop-portal-hyprland
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Hyprland Stuff
    hyprcursor # 鼠标
    hypridle # 休眠
    hyprlock # 锁屏
    hyprpicker # 提取色素
    hyprsunset # 护眼
    hyprshot # 截图
    nwg-displays # 管理显示器
    nwg-dock-hyprland # dock栏

    # hyprpanel
    hyprpanel # a bar
    wf-recorder # record by hyprpanel
    matugen # 图片取色 by hyprpanel
    libgtop # 获取系统性能信息的库

  ];
}
