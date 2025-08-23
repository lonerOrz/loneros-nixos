{
  pkgs,
  ...
}:
let
  QQ = pkgs.callPackage ../pkgs/qq/package.nix { };
in
{
  environment.systemPackages = [
    (QQ.override {
      commandLineArgs = [
        # Force to run on Wayland
        "--wayland-text-input-version=3"
        "--disable-gpu"
      ];
    })
  ];
}
