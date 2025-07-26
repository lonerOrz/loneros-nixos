{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  nodejs,
  pnpm_9,
  pkg-config,
  libayatana-appindicator,
  glib,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook4,
  glib-networking,
  cacert,
  libXtst,
  xdg-utils,
  jq,
  makeWrapper,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bongocat";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "ayangweb";
    repo = "BongoCat";
    rev = "v${finalAttrs.version}";
    hash = "sha256-k9RHO0t81AUV5I18EGfAUY7G/MgYyWHjoJVm+Of0oMc=";
  };

  sourceRoot = "${finalAttrs.src.name}";

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 1;
    hash = "sha256-NI0kyXlARPjpSgmlDq8WiSBdd8WAh0c7TiskHQE1VGI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-8vU70ZIMTaypNhomest8u8wWBexXslF1lITY3bmPjTM=";

  cargoRoot = "./";
  buildAndTestSubdir = "src-tauri";

  tauriBundleType = "deb";

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm_9.configHook
    pkg-config
    xdg-utils
    jq
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    glib
    gtk3
    webkitgtk_4_1
    libayatana-appindicator
    cacert
    libXtst
  ];

  patchPhase = ''
    jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
      > tmp.json && mv tmp.json src-tauri/tauri.conf.json

        mkdir -p src-tauri/icons
        base64 -d > src-tauri/icons/32x32.png <<EOF
    iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABUUlEQVR4nO2XwU3DMBBFb/9LK+htbFE0
    QrCQ7mAtbHjY7z6Tp1EXxzVhnTzZIBL7kwFRAEQRAEQRAEQRAEQpKAHvx7uf2AOPP3WaDJPJKhGo1EUv
    H1GcJ8/FlwDvgGdgFr7DcEIvzjWkuOIQ9sMHNTPB5gFcCP4Fdk3sc9bU4wDlHX62Z+E3AGFgIdHX5Hs4
    gFnYeAcIM8CQ9ZJzYcAvYTURqNEqMeJ4TlmWZVmZ3+dK1Psf0ALa3SRwTPIstEHHYZAFIo5CZew6kC4g
    YzA2mkfYFx7exf6Cc2XQ3kJrDYYWxLMseixjvwd+7LPcA+BQWwGfj8H5WwDnAHtRzPhSFAEQRAEQRAEQ
    RAEQ5LEfx3cfnaU+LEMAAAAASUVORK5CYII=
    EOF
  '';

  preBuild = ''
    export NODE_EXTRA_CA_CERTS=${cacert}/etc/ssl/certs/ca-bundle.crt
    export HOME=$(mktemp -d)
    pnpm install --frozen-lockfile
    pnpm run build:icon
    pnpm run build:vite
  '';

  installPhase = ''
    install -Dm755 target/x86_64-unknown-linux-gnu/release/bongo-cat $out/libexec/bongocat
    install -Dm644 src-tauri/BongoCat.desktop $out/share/applications/BongoCat.desktop

    mkdir -p $out/dist
    cp -r dist/* $out/dist/

    mkdir -p $out/usr/lib/BongoCat/assets
    cp -r src-tauri/assets/* $out/usr/lib/BongoCat/assets/

    makeWrapper $out/libexec/bongocat $out/bin/bongocat \
      --set APPDIR $out \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ libayatana-appindicator ]}:$LD_LIBRARY_PATH
  '';

  meta = {
    description = "Desktop mascot app featuring animated cat drummer";
    homepage = "https://github.com/ayangweb/BongoCat";
    mainProgram = "bongocat";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
