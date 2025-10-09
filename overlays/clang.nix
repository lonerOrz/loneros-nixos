# clang
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
    # 保留原有编译标志，Clang 下追加 -Wno-error=format-security
    env.NIX_CFLAGS_COMPILE = toString (
      (oldAttrs.NIX_CFLAGS_COMPILE or [ ])
      ++ super.lib.optional super.stdenv.cc.isClang [ "-Wno-error=format-security" ]
    );
  });
}
