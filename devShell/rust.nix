{ pkgs, ... }:

pkgs.mkShell {
  buildInputs = (
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
  };

  shellHook = ''
    export PATH="$CARGO_HOME/bin:$PATH"
    echo "🦀 Rust environment loaded"
  '';
}
