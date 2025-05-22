{
  inputs,
  pkgs,
  system,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (inputs.quickshell.packages.${system}.default.override {
      withJemalloc = true;
      withQtSvg = true;
      withWayland = true;
      withX11 = false;
      withPipewire = true;
      withPam = true;
      withHyprland = true;
      withI3 = false;
    })

    kdePackages.qtbase
    kdePackages.qtgraphs
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia
  ];
}
