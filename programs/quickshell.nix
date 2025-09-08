{
  inputs,
  pkgs,
  system,
  ...
}:
let
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

  quickshell = baseQuickshell.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram $out/bin/quickshell \
        --prefix QML_IMPORT_PATH:"${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtbase}/lib/qt5/qml"
    '';
  });
in
{
  environment.systemPackages = with pkgs; [
    quickshell

    kdePackages.qtbase
    kdePackages.qtgraphs
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia

    qt6Packages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
