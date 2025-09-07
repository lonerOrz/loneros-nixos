self: super: {
  linux-pam = super.linux-pam.overrideAttrs (
    old:
    if old.version == "1.7.1" then
      {
        patches = (old.patches or [ ]) ++ [
          ./fix-version-script.patch
        ];
      }
    else
      { }
  );

  # libxslt = super.libxslt.overrideAttrs (old: {
  #   configureFlags = (old.configureFlags or [ ]) ++ [ "--without-python" ];
  # });

  libxslt = super.libxslt.overrideAttrs (old: {
    python = super.python3;
    buildInputs = (old.buildInputs or [ ]) ++ [
      super.libxml2
      super.python3
    ];
  });

  bmake = super.bmake.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./disable-cmd-interrupt.patch
    ];
  });

  buf = super.buf.overrideAttrs (old: {
    # 跳过测试
    doCheck = false;
  });

  python3Packages = super.python3Packages // {
    uncertainties = super.python3Packages.uncertainties.overrideAttrs (old: {
      doCheck = false;
    });
  };
}
