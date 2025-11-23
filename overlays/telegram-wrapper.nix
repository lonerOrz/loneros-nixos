self: super: {
  telegram-desktop-wrapper = super.stdenv.mkDerivation {
    pname = "telegram-desktop-wrapper";
    version = "${super.telegram-desktop.version}";

    nativeBuildInputs = [ super.makeWrapper ];
    buildInputs = [ super.telegram-desktop ];

    unpackPhase = "true"; # 没有源码
    buildPhase = "true"; # 不需要构建

    installPhase = ''
      mkdir -p $out/{share,bin}
      cp -r ${super.telegram-desktop}/share/* $out/share/
      makeWrapper \
        ${super.telegram-desktop}/bin/Telegram \
        $out/bin/telegram-desktop \
        --prefix PATH : $PATH
    '';
  };
}
