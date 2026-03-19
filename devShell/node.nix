{ pkgs }:

pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      nodejs_22
      yarn
      pnpm
      eslint_d
    ]
  );

  env = {
    NPM_CONFIG_PREFIX = "$HOME/.npm";
  };

  shellHook = ''
    export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
    echo "📦 Node.js environment loaded"
  '';
}
