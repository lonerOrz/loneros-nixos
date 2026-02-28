self: super: {
  python3Packages = super.python3Packages // {
    pygobject-stubs = super.python3Packages.pygobject-stubs.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [
        super.python3Packages.typing-extensions
      ];
    });
  };
}
