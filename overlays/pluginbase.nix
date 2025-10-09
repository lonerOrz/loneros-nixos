# https://github.com/NixOS/nixpkgs/pull/449836
self: super: {
  python3Packages = super.python3Packages // {
    pluginbase = super.python3Packages.pluginbase.overrideAttrs (oldAttrs: {
      pyproject = true;

      src = super.fetchPypi {
        inherit (oldAttrs) pname version;
        hash = "sha256-/2wzqY/OIy6cc4QdeHpkPeV0k3Bp8NGBRwKNcNfe4oc=";
      };

      build-system = [ super.python3Packages.setuptools ];

      doCheck = false;
      installCheckPhase = ''
        echo "Skipping installCheckPhase"
      '';

      pythonImportsCheck = [ "pluginbase" ];
    });
  };
}
