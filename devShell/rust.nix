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
    RUST_BACKTRACE = "1";
    RUST_SRC_PATH = "${pkgs.rustc}/lib/rustlib/src/rust/library";
  };

  shellHook = ''
    export PATH="$CARGO_HOME/bin:$PATH"
    echo "🦀 Rust environment loaded"
  '';
}
