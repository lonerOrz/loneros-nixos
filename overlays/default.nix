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
    (import ./tuckr.nix)

    # temporary
    # (import ./clang.nix)
    (import ./pamixer.nix)
    # (import ./rust-cbindgen.nix)
    (import ./vcpkg-tool.nix)
  ];
}
