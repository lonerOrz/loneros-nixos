{ pkgs, ... }:

{
  packages = (
    with pkgs;
    [
      lua5_4_compat
      luarocks
    ]
  );

  shellHook = ''
    echo "🌙 Lua environment loaded"
  '';
}
