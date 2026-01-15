# done https://github.com/NixOS/nixpkgs/pull/479433
self: super: {
  librecad = super.librecad.overrideAttrs (oldAttrs: {
    src = oldAttrs.src.overrideAttrs (oldSrc: {
      hash = "sha256-pun0mMCIsL8XfFlP14EkpBitNHL4OKezPfAF17D9pLg=";
    });
  });
}
