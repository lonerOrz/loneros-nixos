(self: super: {
  coreutils = super.coreutils.overrideAttrs (old: {
    doCheck = false;
  });
})
