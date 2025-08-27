# https://github.com/NixOS/nixpkgs/pull/437213
self: super: {
  tectonic-unwrapped = super.tectonic-unwrapped.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./fix-implicit-autoref.patch ];
  });
}
