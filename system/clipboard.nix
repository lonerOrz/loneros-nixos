{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    cliphist # 管理和查看剪贴板历史记录
    wl-clipboard # 命令行工具，操作剪贴板
  ];
}
