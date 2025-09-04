self: super: {
  loc = super.loc.overrideAttrs (drv: rec {
    name = "loc-${version}";
    version = "0.4.0";

    src = super.fetchFromGitHub {
      owner = "cgag";
      repo = "loc";
      rev = "v${version}";
      sha256 = "0cdcalfb0njvlswwvzbp0s7lwfqx4acxcmlsjw2bkanszbdz10s8";
    };

    cargoDeps = drv.cargoDeps.overrideAttrs (
      super.lib.const {
        name = "${name}-vendor";
        inherit src;
        outputHash = "1qiib37qlm1z239mfr5020m4a1ig2abhlnwava7il8dqvrxzsxpl";
      }
    );
  });
}
