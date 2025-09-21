# https://github.com/NixOS/nixpkgs/pull/444116
self: super: {
  podman = super.callPackage ./podman.nix { };
}
