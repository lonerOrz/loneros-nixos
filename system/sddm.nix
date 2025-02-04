{
  pkgs,
  username,
  ...
}:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm; # 确保使用 Qt 6 版本的 SDDM
    # settings = {
    #   Autologin = {
    #     Session = "Hyprland";
    #     User = "${username}";
    #   };
    # };
    enableHidpi = true;
    autoNumlock = true;
    # 我直接在catppuccin统一设置程序风格，具体查看programs/catppuccin.nix
    # theme = "sugar-dark";
  };
  environment.systemPackages = let themes = pkgs.callPackage ../pkgs/sddm-themes.nix {}; in [ 
    pkgs.elegant-sddm # Elegant
    themes.sugar-dark # sugar-dark
  ];
}
