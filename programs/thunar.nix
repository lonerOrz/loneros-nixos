{
  pkgs,
  ...
}:
{
  programs = {
    thunar = {
      enable = true;
      plugins = with pkgs; [
        xfce4-exo # XFCE 框架库
        mousepad # 文本编辑器
        thunar-archive-plugin # 管理压缩文件
        thunar-volman # 挂载和卸载移动设备
        tumbler # 生成文件缩略图的后台服务
      ];
    };
  };
  environment.systemPackages = [
    pkgs.ffmpegthumbnailer # Need For Video / Image Preview
  ];
}
