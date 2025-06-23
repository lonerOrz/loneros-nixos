{
  pkgs ? import <nixpkgs> { },
}:
let
  lib = pkgs.lib;
  list = builtins.readDir ./.;
  files = builtins.attrNames (lib.filterAttrs (_: v: v == "regular") list);
in
builtins.listToAttrs (
  map (file: {
    name = lib.replaceStrings [ ".nix" ] [ "" ] file;
    value = pkgs.callPackage ./${file} { };
  }) files
)
