self: super: {
  tectonic-unwrapped = super.tectonic-unwrapped.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./fix-implicit-autoref.patch ];
  });
}
