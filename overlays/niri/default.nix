# https://github.com/YaLTeR/niri/pull/1791
self: super: {
  niri-unstable = super.niri-unstable.overrideAttrs (oldAttrs: rec {
    patches = oldAttrs.patches or [ ] ++ [
      ./support-shm-shareing.patch
    ];
  });
}
