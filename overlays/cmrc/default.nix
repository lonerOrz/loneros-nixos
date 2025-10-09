# https://github.com/NixOS/nixpkgs/pull/450116
self: super: {
  cmakerc = super.cmakerc.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./0001-Fix-minimum-required-CMake-version-to-be-compatible-.patch
    ];
  });
}
