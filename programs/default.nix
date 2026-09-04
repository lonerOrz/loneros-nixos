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
      "anime-game-launcher"
      "clash"
      "fabric"
      "hcml"
      "neomutt"
      "nvf"
      "radicle"
      "spicetify"
      "steam"
      "tmux"
      "virtualbox"
      "virt-manager"
      "vxwm"
    ];
  };
}
