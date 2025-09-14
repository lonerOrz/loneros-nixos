# https://github.com/NixOS/nixpkgs/pull/442624
self: super: {
  lix = super.lix.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (super.fetchpatch2 {
        name = "lix-lowdown-1.4.0.patch";
        url = "https://git.lix.systems/lix-project/lix/commit/858de5f47a1bfd33835ec97794ece339a88490f1.patch";
        hash = "sha256-FfLO2dFSWV1qwcupIg8dYEhCHir2XX6/Hs89eLwd+SY=";
      })
    ];
  });
}
