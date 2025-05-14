{
  pkgs,
  ...
}:
{
  # 系统基本环境，用于软件运行
  environment.systemPackages =
    (with pkgs; [
      node2nix
      nodejs_22
    ])
    ++ (with pkgs.nodePackages; [
      yarn
      pnpm
    ])
    ++ (with pkgs; [
      python312
      pyright
    ])
    ++ (with pkgs.python312Packages; [
      uv # manager python env
      requests
      pyquery # needed for hyprland-dots Weather script
      gpustat # gpu status
    ])
    ++ (with pkgs; [
      # lua
      lua5_4_compat
      luarocks

      # c/c++
      gcc # GNU C 编译器
      gdb # GNU 调试器
      clang # LLVM C/C++ 编译器
      lldb # LLVM 调试器
      cmake # CMake 构建系统
    ]);
}
