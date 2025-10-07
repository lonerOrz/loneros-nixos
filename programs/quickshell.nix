{
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  extraQmlPath = lib.makeSearchPath "lib/qt-6/qml" (
    with pkgs;
    [
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtmultimedia
      qt6.qt5compat
    ]
  );

  fontconfig = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [
      material-symbols
      nerd-fonts.caskaydia-mono
    ];
  };

  baseQuickshell = inputs.quickshell.packages.${system}.default.override {
    withJemalloc = true;
    withQtSvg = true;
    withWayland = true;
    withX11 = false;
    withPipewire = true;
    withPam = true;
    withHyprland = true;
    withI3 = true;
  };

  quickshellWrapped =
    pkgs.runCommand "quickshell-wrapped"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildInputs = [ baseQuickshell ];
      }
      ''
        mkdir -p $out/bin

        for exe in ${baseQuickshell}/bin/*; do
          [ -x "$exe" ] || continue

          makeWrapper "$exe" "$out/bin/$(basename $exe)" \
            --set FONTCONFIG_FILE "${fontconfig}/etc/fonts/fonts.conf" \
            --set QML2_IMPORT_PATH "${extraQmlPath}"
        done
      '';
in
{
  environment.systemPackages = with pkgs; [
    quickshellWrapped

    kdePackages.qtbase
    kdePackages.qtgraphs
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia

    qt6Packages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
