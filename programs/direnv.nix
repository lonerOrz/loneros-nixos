{
  pkgs,
  ...
}:
{
  # 启用 direnv 并确保支持 nix-direnv
  programs.direnv = {
    enable = true;
    loadInNixShell = true; # nix develop 中启用 direnv 的加载
    enableFishIntegration = true; # 启用 direnv 在 fish 中的集成
    # enableBashIntegration = true;
    # enableBashIntegration = true;
    nix-direnv.enable = true; # 启用 nix-direnv 以与 nix 环境配合使用
    silent = false; # 启用direnv日志记录的隐藏
  };

  environment.systemPackages = [
    pkgs.devbox # 配合 direnv
  ];
}
