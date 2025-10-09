# https://github.com/NixOS/nixpkgs/pull/450150
self: super: {
  python3Packages = super.python3Packages // {
    pytomlpp = super.python3Packages.pytomlpp.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches or [ ] ++ [ ./0001-remove-setup_requires.patch ];
    });
  };
}
