{
  pkgs,
  ...
}:

{
  imports = [
    ./xdg-mime.nix
    ./xdg-portal.nix
  ];

  environment.systemPackages = with pkgs; [
    xdg-user-dirs # 标准用户目录初始化
    xdg-utils # 桌面环境集成接口
  ];
}
