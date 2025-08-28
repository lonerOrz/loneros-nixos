{
  lib,
  pkgs ? import <nixpkgs> { },
}:

let
  autoImport = import ./autoimport.nix;
  baseGetRaw = import ./getRaw.nix;
  callImport = import ./callImport.nix { inherit pkgs; };
in
{
  toUpperCase = str: lib.toUpper str;
  prefixedAttrs = prefix: attrs: lib.mapAttrs (name: value: { "${prefix}-${name}" = value; }) attrs;
  packageVersions =
    pkg: versions:
    let
      attrs = map (v: {
        name = "${pkg}-${v}";
        value = {
          version = v;
        };
      }) versions;
    in
    lib.listToAttrs attrs;

  importModule' =
    path: extra:
    import path {
      lib = lib;
      extra = extra;
    };
  getRaw = url: baseGetRaw { inherit lib url; };
  inherit autoImport callImport;
}
