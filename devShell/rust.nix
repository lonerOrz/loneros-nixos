{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
  ];

  env = {
    CARGO_HOME = "$HOME/.cargo";
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  shellHook = ''
    export PATH="$CARGO_HOME/bin:$PATH"
    echo "🦀 Rust environment loaded"
  '';
}
