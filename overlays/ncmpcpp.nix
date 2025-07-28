self: super: {
  ncmpcpp = super.ncmpcpp.overrideAttrs (old: {
    configureFlags = (old.configureFlags or [ ]) ++ [
      (super.lib.withFeatureAs true "boost" super.boost.dev)
    ];
  });
}
