{
  lib,
  libGL,
  cairo,
  dbus,
  eudev,
  fetchFromGitHub,
  installShellFiles,
  libdisplay-info,
  libinput,
  libxkbcommon,
  libgbm,
  pango,
  pipewire,
  pkg-config,
  rustPlatform,
  seatd,
  stdenv,
  systemd,
  wayland,
  withDbus ? true,
  withDinit ? false,
  withScreencastSupport ? true,
  withSystemd ? true,
  withLto ? false,
  withNative ? false,
}:
let
  raw-version = "25.11.0";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-blur";
  version = "${raw-version}" + "-feat-blur";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "niri";
    rev = "b625076600915df258fac82479ec76d27233b866";
    hash = "sha256-RNGLJ1akCrTHH4r89TAij05KIWt+Mf2d+vWih74elfk=";
  };

  cargoHash = "sha256-mkdn5QY0tWSQ1GhanMNu7v6KiaooSs2oYuvskvzVD3s=";

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    # 将平铺窗口的实现方式也换成 true blur 方式
    # ./fix-blur.patch
  ];

  postPatch = ''
    patchShebangs resources/niri-session

    substituteInPlace resources/niri.service \
      --replace-fail 'ExecStart=niri ' \
                     'ExecStart=${placeholder "out"}/bin/niri '
  '';

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    cairo
    dbus
    libGL
    libdisplay-info
    libinput
    seatd
    libxkbcommon
    libgbm
    pango
    wayland
  ]
  ++ lib.optional (withDbus || withScreencastSupport || withSystemd) dbus
  ++ lib.optional withScreencastSupport pipewire
  ++ lib.optional withSystemd systemd # 包含 libudev
  ++ lib.optional (!withSystemd) eudev; # 在不使用 systemd 时，用作替代的 libudev 实现

  buildFeatures =
    lib.optional withDbus "dbus"
    ++ lib.optional withDinit "dinit"
    ++ lib.optional withScreencastSupport "xdp-gnome-screencast"
    ++ lib.optional withSystemd "systemd";
  buildNoDefaultFeatures = true;

  # ever since this commit:
  # https://github.com/YaLTeR/niri/commit/771ea1e81557ffe7af9cbdbec161601575b64d81
  # niri now runs an actual instance of the real compositor (with a mock backend) during tests
  # and thus creates a real socket file in the runtime dir.
  # this is fine for our build, we just need to make sure it has a directory to write to.
  preCheck = ''
    export XDG_RUNTIME_DIR="$(mktemp -d)"
  '';

  postInstall = ''
    install -Dm0644 README.md resources/default-config.kdl -t $doc/share/doc/niri
    mv docs/wiki $doc/share/doc/niri/wiki

    install -Dm0644 resources/niri.desktop -t $out/share/wayland-sessions
  ''
  + lib.optionalString withDbus ''
    install -Dm0644 resources/niri-portals.conf -t $out/share/xdg-desktop-portal
  ''
  + lib.optionalString (withSystemd || withDinit) ''
    install -Dm0755 resources/niri-session -t $out/bin
  ''
  + lib.optionalString withSystemd ''
    install -Dm0644 resources/niri{-shutdown.target,.service} -t $out/lib/systemd/user
  ''
  + lib.optionalString withDinit ''
    install -Dm0644 resources/dinit/niri{-shutdown,} -t $out/lib/dinit.d/user
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd $pname \
      --bash <($out/bin/niri completions bash) \
      --fish <($out/bin/niri completions fish) \
      --zsh <($out/bin/niri completions zsh)
  '';

  env = {
    # 强制链接 libEGL 和 libwayland-client
    # 这样在运行时可以通过 dlopen() 被发现
    RUSTFLAGS =
      (toString (
        map (arg: "-C link-arg=" + arg) [
          "-Wl,--push-state,--no-as-needed"
          "-lEGL"
          "-lwayland-client"
          "-Wl,--pop-state"
        ]
      ))
      + " -C debuginfo=line-tables-only"
      + lib.optionalString withNative " -C target-cpu=native"
      + lib.optionalString withLto " -C lto=thin -C opt-level=3";

    # 上游建议在没有 Git 仓库的构建环境中手动设置提交 hash
    # 参考：https://github.com/YaLTeR/niri/wiki/Packaging-niri#version-string
    NIRI_BUILD_COMMIT = "NUR";
  };

  checkFlags = [
    # These tests require the ability to access a "valid EGL Display", but that won't work
    # inside the Nix sandbox
    "--skip=::egl"
  ];

  passthru.providedSessions = [ "niri" ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Scrollable-tiling Wayland compositor";
    homepage = "https://github.com/YaLTeR/niri";
    changelog = "https://github.com/YaLTeR/niri/releases/tag/v${raw-version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "niri";
  };
})
