{
  pkgs,
  ...
}:
let
  QQ = pkgs.nur.repos.lonerOrz.qq;
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
