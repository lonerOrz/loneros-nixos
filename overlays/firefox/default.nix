self: super:
let
  make-icu = import ./make-icu.nix {
    stdenv = super.stdenv;
    lib = super.lib;
    buildPackages = super.buildPackages;
    fetchurl = super.fetchurl;
    fixDarwinDylibNames = super.fixDarwinDylibNames;
    testers = super.testers;
    updateAutotoolsGnuConfigScriptsHook = super.updateAutotoolsGnuConfigScriptsHook;
  };
  icu78 = make-icu {
    version = "78.1";
    hash = "sha256-Yhf1jKObIxJ2Bc/Gx+DTR1/ksNYxVwETg9cWy0FheIY=";
  };
in
{
  firefox-unwrapped_nightly = super.firefox-unwrapped_nightly.overrideAttrs (
    oldAttrs:
    let
      icuDep =
        if super.lib.versionAtLeast oldAttrs.version "147" then
          icu78
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
