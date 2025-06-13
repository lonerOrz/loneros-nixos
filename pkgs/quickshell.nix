{
  symlinkJoin,
  makeWrapper,
  quickshell,
  kdePackages,
  material-symbols,
  makeFontsConf,
  nerd-fonts,
  lib,
}:
symlinkJoin rec {
  name = "qs-wrapper";
  paths = [ quickshell ];

  buildInputs = [ makeWrapper ];

  qtDeps = [
    kdePackages.qtbase
    kdePackages.qtgraphs
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia
  ];

  qmlPath = lib.pipe qtDeps [
    (builtins.map (lib: "${lib}/lib/qt-6/qml"))
    (builtins.concatStringsSep ":")
  ];

  # requried when nix running directly
  fontconfig = makeFontsConf {
    fontDirectories = [
      material-symbols
      nerd-fonts.caskaydia-mono
    ];
  };

  postBuild = ''
    wrapProgram $out/bin/quickshell \
      --set FONTCONFIG_FILE "${fontconfig}" \
      --set QML2_IMPORT_PATH "${qmlPath}" \
  '';

  meta.mainProgram = "quickshell";
}
