# https://github.com/NixOS/nixpkgs/pull/454410
self: super: {
  rust-cbindgen = super.rust-cbindgen.overrideAttrs (old: rec {
    version = "0.29.1";

    src = super.fetchFromGitHub {
      owner = "mozilla";
      repo = "cbindgen";
      rev = "v${version}";
      hash = "sha256-w1vLgdyxyZNnPQUJL6yYPHhB99svsryVkwelblEAisQ=";
    };

    # cargoDeps = old.cargoDeps.overrideAttrs (
    #   super.lib.const {
    #     name = "${old.pname}-vendor.tar.gz";
    #     inherit src;
    #     # outputHashMode = "recursive";
    #     outputHash = "sha256-m/VTg6Lrv1jfi4GxWA1biu3FRQ50b7yHltTmF+E8GtI=";
    #   }
    # );

    cargoDeps = self.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-POpdgDlBzHs4/fgV1SWSWcxVrn0UTTfvqYBRGqwD98s=";
    };
  });
}
