{
  pkgs,
  inputs,
  username,
  ...
}:
let
  zero-bg = pkgs.fetchurl {
    url = "https://www.desktophut.com/files/kV1sBGwNvy-Wallpaperghgh2Prob4.mp4";
    hash = "sha256-VkOAkmFrK9L00+CeYR7BKyij/R1b/WhWuYf0nWjsIkM=";
  };
  silent-sddm = inputs.silentSDDM.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    # one of configs/<$theme>.conf
    theme = "rei";
    # aditional backgrounds
    # extraBackgrounds = [ zero-bg ];
    # overrides config set by <$theme>.conf
    # theme-overrides = {
    #   # Available options: https://github.com/uiriansan/SilentSDDM/wiki/Options
    #   "LoginScreen.LoginArea.Avatar" = {
    #     shape = "circle";
    #     active-border-color = "#ffcfce";
    #   };
    #   "LoginScreen" = {
    #     background = "${zero-bg.name}";
    #   };
    #   "LockScreen" = {
    #     background = "${zero-bg.name}";
    #   };
    # };
  };
  astronaut-sddm = pkgs.nur.repos.lonerOrz.astronaut-sddm.override {
    # https://github.com/Keyitdev/sddm-astronaut-theme
    theme = "hyprland_kath";
    # themeConfig={
    #   General = {
    #     HeaderText ="Hi";
    #     Background="/home/${username}/Desktop/wp.png";
    #     FontSize="9.0";
    #   };
    # };
  };
  sddm-theme = silent-sddm;
in
{
  # 自动登录
  services.displayManager.autoLogin = {
    enable = true;
    user = "${username}";
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm; # 确保使用 Qt 6 版本的 SDDM
    enableHidpi = true;
    autoNumlock = true;
    theme = sddm-theme.pname;
    extraPackages =
      with pkgs;
      [
        kdePackages.qtsvg
        kdePackages.qtmultimedia
        kdePackages.qtvirtualkeyboard
      ]
      ++ silent-sddm.propagatedBuildInputs;
    settings = {
      # required for styling the virtual keyboard
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };
  environment.systemPackages = [
    pkgs.elegant-sddm # Elegant
    astronaut-sddm
    silent-sddm
    silent-sddm.test
  ];
}
