{
  description = "Rust development environment using Nix Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay, ... }:
  let
    system = "x86_64-linux"; # 目标系统架构
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ rust-overlay.overlays.default ]; # 使用 Rust Overlay
    };

    # 从 toolchain.toml 中生成 Rust 工具链
    toolchain = pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;

  in {
    # 这里是开发环境的定义
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        toolchain
        pkgs.pkg-config        # 添加 pkg-config
        pkgs.dbus              # 用 dbus 替换 libdbus
        pkgs.openssl           # 添加 OpenSSL
      ];

      shellHook = ''
        export RUST_SRC_PATH="${toolchain}/lib/rustlib/src/rust/library"
      '';
    };
  };
}

