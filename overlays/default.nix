{
  nixpkgs.overlays = [
    # forever
    (import ./code-cursor-wrapper.nix)
    (import ./vscodium-wrapper.nix)
    (import ./spotify-wrapper.nix)
    (import ./obsidian-wrapper.nix)
    (import ./sparkle-wrapper.nix)
    (import ./mpv.nix)
    (import ./atuin)
    (import ./lib.nix)
    (import ./niri)

    # temporary
    (import ./pamixer.nix)
    (import ./conan.nix)
    (import ./pygobject-stubs.nix)
    (import ./node2nix.nix)
    (import ./ncmpcpp.nix)
  ];
}
