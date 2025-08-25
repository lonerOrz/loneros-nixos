self: super:
let
  myLib = import ../lib { lib = super.lib; };
in
{
  lib = super.lib // myLib;
}
