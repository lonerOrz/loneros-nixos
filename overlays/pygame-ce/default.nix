# done https://github.com/NixOS/nixpkgs/pull/513890
self: super: {
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (python-self: python-super: {
      pygame-ce = python-super.pygame-ce.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          ./fix-font-test-size-tolerance.patch
        ];
      });
    })
  ];
}
