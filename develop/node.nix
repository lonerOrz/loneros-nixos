{
  description = "Node.js Development Environment using Nix Flakes";

  # 定义 Flake 输入
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # 使用最新的 nixpkgs
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux"; # 目标架构
    pkgs = import nixpkgs {
      inherit system;
    };

    # 必要的工具链和工具
    buildInputs = with pkgs; [
      nodejs            # Node.js
      npm               # Node.js 包管理工具
      yarn              # 另一种流行的 Node.js 包管理工具
      make              # Make 工具（通常用于构建 Node.js 项目）
      buildPackages     # 额外的构建工具包
      pkg-config        # 用于查找库路径的工具
    ];

  in {
    # 定义开发环境
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = buildInputs;

      # 可选的 shellHook 设置
      shellHook = ''
        echo "Welcome to the Node.js development environment!"
      '';
    };
  };
}

