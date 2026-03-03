{
  lib,
  pkgs ? import <nixpkgs> { },
}:

let
  autoImport = import ./autoImport.nix;
  baseGetRaw = import ./getRaw.nix;
  callImport = import ./callImport.nix { inherit pkgs; };
  flattenAttrset = import ./flattenAttrset.nix { inherit lib; };
in
{
  inherit autoImport callImport flattenAttrset;

  getRaw = url: baseGetRaw { inherit lib url; };

  toUpperCase = str: lib.toUpper str;

  prefixedAttrs =
    prefix: attrs:
    lib.listToAttrs (
      lib.mapAttrsToList (name: value: {
        name = "${prefix}-${name}";
        value = value;
      }) attrs
    );

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

  mkOutOfStoreSymlink =
    sourcePath:
    let
      replaceChars =
        str:
        builtins.foldl' (s: kv: builtins.replaceStrings [ kv.key ] [ kv.value ] s) str [
          {
            key = "/";
            value = "-";
          }
          {
            key = ".";
            value = "_";
          }
        ];
      sourceStr = toString sourcePath;
      storeName = "out-of-store-${replaceChars sourceStr}";
    in
    pkgs.runCommandLocal storeName { } ''
      ln -s "${sourceStr}" $out
    '';
}
