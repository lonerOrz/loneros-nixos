{ lib }:

let
  autoImport = import ./autoimport.nix;
  baseGetRaw = import ./getRaw.nix;
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
  inherit autoImport;
  getRaw = url: baseGetRaw { inherit lib url; };
}
