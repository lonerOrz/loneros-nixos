{ lib, pkgs, ... }:

let
  mylib = import ../lib/default.nix {
    inherit lib pkgs;
  };
in
{
  imports = mylib.autoImport {
    dir = ./.;
    exclude = [
      "clash"
      "nvf"
      "virtualbox"
      "fabric"
    ];
  };
}
