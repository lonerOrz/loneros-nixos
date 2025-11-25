{ pkgs, ... }:

{
  packages = (
    with pkgs;
    [
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy
    ]
  );

  env = {
    CARGO_HOME = "$HOME/.cargo";
    PATH = "$CARGO_HOME/bin:$PATH";
  };

  shellHook = ''
    echo "🦀 Rust environment loaded"
  '';
}
