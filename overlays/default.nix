inputs: {
  nixpkgs.overlays =
    let
      permanent = [
        "code-cursor-wrapper.nix"
        "vscodium-wrapper.nix"
        "spotify-wrapper.nix"
        "obsidian-wrapper.nix"
        "sparkle-wrapper.nix"
        "mpv.nix"
        "atuin"
        "lib.nix"
        "niri"
      ];

      temporary = [
      ];

      overlayImport = files: map (f: import (./. + "/${f}")) files;

    in
    overlayImport permanent
    ++ overlayImport temporary
    ++ [
      (import ./hotfixes.nix inputs)
    ];
}
