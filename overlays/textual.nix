#https://github.com/NixOS/nixpkgs/issues/425335
{ inputs }:

final: prev: {
  python3Packages = prev.python3Packages // {
    textual = inputs.nixpkgs-stable.legacyPackages.${prev.system}.python3Packages.textual;
  };
}
