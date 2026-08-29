{ pkgs, ... }:

pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      lua5_5_compat
      luarocks
    ]
  );

  shellHook = ''
    echo "🌙 Lua environment loaded"
  '';
}
