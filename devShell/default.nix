{ pkgs, ... }:
{
  dev = import ./dev.nix { inherit pkgs; };
  # node = import ./node.nix {inherit pkgs;};
  # python = import ./python.nix {inherit pkgs;};
  # rust = import ./rust.nix {inherit pkgs;};
}
