{
  inputs,
  pkgs,
  system,
  ...
}:
let
  quickshell = pkgs.callPackage ./pkgs/quickshell.nix {
    quickshell = inputs.quickshell.packages.${system}.default.override {
      withJemalloc = true;
      withQtSvg = true;
      withWayland = true;
      withX11 = false;
      withPipewire = true;
      withPam = true;
      withHyprland = true;
      withI3 = false;
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    quickshell

    kdePackages.qtbase
    kdePackages.qtgraphs
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia
  ];
}
