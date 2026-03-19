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
    xdg-user-dirs # 创建标准的用户目录结构
    xdg-utils # 用于桌面环境集成的工具，提供对桌面环境设置和操作的统一接口
  ];
}
