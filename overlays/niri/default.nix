# https://github.com/YaLTeR/niri/pull/1791
self: super: {
  niri = super.niri.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches or [ ] ++ [
      ./support-shm-shareing.patch
    ];
  });

  niri-git = super.nur.repos.lonerOrz.niri-git.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches or [ ] ++ [
      (super.fetchpatch2 {
        url = "https://patch-diff.githubusercontent.com/raw/niri-wm/niri/pull/3246.patch";
        hash = "sha256-wdiMj0dRmmf0/LcetJUEXZVPBlonQwY5lIx87a3BG6I=";
      })
    ];
  });

}
