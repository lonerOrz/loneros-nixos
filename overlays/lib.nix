self: super:
let
  myLib = import ../lib {
    lib = super.lib;
    pkgs = super;
  };
in
{
  lib = super.lib // myLib;
}
