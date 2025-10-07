{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  nss,
  nspr,
  alsa-lib,
  openssl,
  webkitgtk_4_1,
  udev,
  libayatana-appindicator,
  libGL,
}:

let
  sources = import ./sources.nix;
  systemSrc = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "mihomo-party";
  version = "1.8.8";

  src = fetchurl {
    url = systemSrc.url;
    hash = systemSrc.hash;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  buildInputs = [
    nss
    nspr
    alsa-lib
    openssl
    webkitgtk_4_1
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt $out/opt
    cp -r usr/share $out/share
    substituteInPlace $out/share/applications/mihomo-party.desktop \
      --replace-fail "/opt/mihomo-party/mihomo-party" "mihomo-party"
    ln -s $out/opt/mihomo-party/mihomo-party $out/bin/mihomo-party
  '';

  preFixup = ''
    patchelf --add-needed libGL.so.1 \
      --add-rpath ${
        lib.makeLibraryPath [
          libGL
          udev
          libayatana-appindicator
        ]
      } $out/opt/mihomo-party/mihomo-party
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Another Mihomo GUI";
    homepage = "https://github.com/mihomo-party-org/mihomo-party";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "mihomo-party";
  };
}
