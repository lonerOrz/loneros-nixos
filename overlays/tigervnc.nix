self: super: {
  tigervnc = super.tigervnc.overrideAttrs (old: rec {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      super.autoconf
      super.automake
      super.libtool
    ];
  });

}
