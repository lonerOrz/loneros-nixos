{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
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

  # baseQuickshell = inputs.quickshell.packages.${system}.default.override {
  #   withX11 = false;
  # };

  baseQuickshell = pkgs.nur.repos.lonerOrz.noctalia-qs; # for noctalia

  # baseQuickshell = pkgs.quickshell; # realease version

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
    kdePackages.qtshadertools

    qt6Packages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
