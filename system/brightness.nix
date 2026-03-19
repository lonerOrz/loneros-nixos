{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    brightnessctl # 控制显示器亮度的命令行工具
    ddcutil # 外置屏幕亮度调节
  ];
}
