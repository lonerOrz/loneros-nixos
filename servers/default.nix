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
      "aria2"
      "docker"
      "ollama"
      # "flatpak"
      "jellyfin"
    ];
  };
}
