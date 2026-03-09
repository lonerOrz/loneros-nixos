{ pkgs, ... }:
{
  packages = (
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
    PATH = "$NPM_CONFIG_PREFIX/bin:$PATH";
  };
  shellHook = ''
    echo "📦 Node.js environment loaded"
  '';
}
