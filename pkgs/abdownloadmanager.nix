{
  lib,
  stdenv,
  fetchurl,
  glibc,
  jdk,
  glib,
  zlib,
  alsa-lib,
  libglvnd,
  libXi,
  freetype,
  libXtst,
  libXrender,
  fontconfig,
  libX11,
  libXext,
  makeWrapper,
  gtk3,
  libxkbcommon,
  libXrandr,
  cairo,
  pango,
}:
stdenv.mkDerivation rec {
  pname = "abdownloadmanager-bin";
  version = "1.6.4";

  src = fetchurl {
    url = "https://github.com/amir1376/ab-download-manager/releases/download/v${version}/ABDownloadManager_${version}_linux_x64.tar.gz";
    sha256 = "sha256-nyYs70Y+uorjpmK20pxIvMj9iTDHItbHN2F/tIEd4os=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    glibc
    jdk
    glib
    zlib
    alsa-lib
    libglvnd
    libXi
    freetype
    libXtst
    libXrender
    fontconfig
    libX11
    libXext

    # GTK 相关依赖
    gtk3
    libxkbcommon
    libXrandr
    cairo
    pango
  ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
        runHook preInstall

        mkdir -p $out/opt/ABDownloadManager
        cp -r ABDownloadManager/* $out/opt/ABDownloadManager/

        mkdir -p $out/bin

        cat > $out/bin/abdm << EOF
    #!/bin/sh
    export GDK_BACKEND=x11
    export JAVA_HOME=${jdk}
    export PATH=\$JAVA_HOME/bin:\$PATH
    export LD_LIBRARY_PATH=${
      lib.makeLibraryPath [
        glib
        libXext
        libX11
        libXtst
        libXrender
        fontconfig
        freetype
        libXi
        zlib
        alsa-lib
        libglvnd
        gtk3
        libxkbcommon
        libXrandr
        cairo
        pango
      ]
    }:\$LD_LIBRARY_PATH
    export JAVA_LIBRARY_PATH=\$JAVA_HOME/lib/server

    cd "$out/opt/ABDownloadManager"
    exec ./bin/ABDownloadManager "\$@"
    EOF

        chmod +x $out/bin/abdm

        install -Dm644 $out/opt/ABDownloadManager/lib/ABDownloadManager.png \
          $out/share/pixmaps/ABDownloadManager.png

        mkdir -p $out/share/applications
        cat > $out/share/applications/ABDownloadManager.desktop << EOF
    [Desktop Entry]
    Name=ABDownloadManager
    Exec=abdm
    Type=Application
    Icon=ABDownloadManager
    Comment=A Kotlin based download manager
    Categories=Network;FileTransfer;
    EOF

        runHook postInstall
  '';

  meta = {
    description = "A Kotlin based download manager";
    homepage = "https://github.com/amir1376/ab-download-manager";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
