#waiting-pr https://github.com/NixOS/nixpkgs/pull/493826
self: super: {
  python3Packages = super.python3Packages // {
    pygobject-stubs = super.python3Packages.pygobject-stubs.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [
        super.python3Packages.typing-extensions
      ];
    });
  };
}
