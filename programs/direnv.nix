{
  config,
  ...
}:
{
  # 启用 direnv 并确保支持 nix-direnv
  programs.direnv = {
    enable = true;
    enableFishIntegration = true; # 启用 direnv 在 fish 中的集成
    nix-direnv.enable = true; # 启用 nix-direnv 以与 nix 环境配合使用
    silent = true; # 启用direnv日志记录的隐藏
  };
}
