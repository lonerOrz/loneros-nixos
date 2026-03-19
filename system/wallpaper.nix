{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    swww # 设置和管理背景壁纸
    mpvpaper # 动态壁纸
    wallust # 图片取色
    imagemagick # 图像处理工具
  ];
}
