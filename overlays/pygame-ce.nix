self: super: {
  python3Packages = super.python3Packages // {
    pygame-ce = super.python3Packages.pygame-ce.overrideAttrs (oldAttrs: {
      doCheck = false;
      doInstallCheck = false;
      pythonImportsCheck = [ ];
    });
  };
}
