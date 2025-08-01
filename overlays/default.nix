{
  nixpkgs.overlays = [
    # forever
    (import ./code-cursor-wrapper.nix)
    (import ./vscodium-wrapper.nix)
    (import ./spotify-wrapper.nix)
    (import ./obsidian-wrapper.nix)
    (import ./mihomo-party-wrapper.nix)
    (import ./mpv.nix)

    #temporary
    (import ./textual.nix)
    (import ./ncmpcpp.nix)
  ];
}
