{
  nixpkgs.overlays = [
    (import ./code-cursor-wrapper.nix)
    (import ./vscodium-wrapper.nix)
    (import ./spotify-wrapper.nix)
    (import ./obsidian-wrapper.nix)
    (import ./mihomo-party-wrapper.nix)
    (import ./mpv.nix)
    (import ./mpd.nix)
    (import ./papirus-icon-theme.nix)
    (import ./textual.nix)
  ];
}
