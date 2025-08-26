self: super: {
  python313Packages = super.python313Packages // {
    i3ipc = super.python313Packages.i3ipc.overrideAttrs (old: {
      doCheck = false;
      checkPhase = ''
        echo "Skipping pytest in Nix build"
      '';
      installCheckPhase = ''
        echo "Skipping install checks in Nix build"
      '';
    });
  };
}
