self: super: {
  audit = super.audit.overrideAttrs (old: {
    configureFlags = (old.configureFlags or [ ]) ++ [ "--disable-python" ];
  });

  kexec-tools = super.kexec-tools.overrideAttrs (oldAttrs: rec {
    preBuild = ''
      echo "Patching kexec_test/Makefile to fix LLD --image-base error..."
      sed -i 's/-Ttext 0x10000/-Ttext 0x0 --image-base=0x0/g' kexec_test/Makefile
    '';
  });

  coreutils = super.coreutils.overrideAttrs (oldAttrs: rec {
    # Clang 编译时 format-security 告警会被视为错误，故追加该选项
    env.NIX_CFLAGS_COMPILE = toString (
      (oldAttrs.NIX_CFLAGS_COMPILE or [ ])
      ++ super.lib.optional super.stdenv.cc.isClang [ "-Wno-error=format-security" ]
    );
  });
}
