self: super: {
  firefox-unwrapped_nightly = super.firefox-unwrapped_nightly.overrideAttrs (
    oldAttrs:
    let
      icuDep =
        if super.lib.versionAtLeast oldAttrs.version "147" then
          super.icu78
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
