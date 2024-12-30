{
  description = "C Development Environment using Nix Flakes";

  # 定义 Flake 输入
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # 使用最新的 nixpkgs
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux"; # 目标架构
    pkgs = import nixpkgs {
      inherit system;
    };

    # 必要的工具链和工具
    buildInputs = with pkgs; [
      gcc                # GCC 编译器
      clang              # Clang 编译器
      make               # Make 工具
      gdb                # GDB 调试器
      valgrind           # Valgrind (内存调试工具)
      pkg-config         # 用于查找库路径的工具
      cmake              # CMake 构建工具
      libtool            # 用于创建共享库的工具
      autoconf           # 自动化构建工具
      automake           # 自动化构建工具
      ninja              # Ninja 构建系统（可选）
    ];

  in {
    # 定义开发环境
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = buildInputs;

      # 可选的 shellHook 设置
      shellHook = ''
        echo "Welcome to the C development environment!"
      '';
    };
  };
}

