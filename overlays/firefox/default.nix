self: super: {
  icu78 = super.callPackage ./make-icu.nix { } {
    version = "78.1";
    hash = "sha256-Yhf1jKObIxJ2Bc/Gx+DTR1/ksNYxVwETg9cWy0FheIY=";
  };

  firefox-unwrapped_nightly = super.firefox-unwrapped_nightly.overrideAttrs (
    oldAttrs:
    let
      icuDep =
        if super.lib.versionAtLeast oldAttrs.version "147" then
          self.icu78
        else if super.lib.versionAtLeast oldAttrs.version "138" then
          super.icu77
        else
          super.icu73;
    in
    {
      buildInputs = builtins.filter (pkg: (pkg.pname or "") != "icu4c") (oldAttrs.buildInputs or [ ]) ++ [
        icuDep
      ];
    }
  );
  firefox_nightly = self.wrapFirefox self.firefox-unwrapped_nightly { };
}
