{
  pkgs,
  username,
  ...
}:
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
    theme = "astronaut";
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qtvirtualkeyboard
    ];
  };
  environment.systemPackages = [
    pkgs.elegant-sddm # Elegant
    (pkgs.callPackage ../pkgs/astronaut-sddm.nix {
      theme = "hyprland_kath";
      # themeConfig={
      #   General = {
      #     HeaderText ="Hi";
      #     Background="/home/${username}/Desktop/wp.png";
      #     FontSize="9.0";
      #   };
      # };
    })
  ];
}
