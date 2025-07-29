{ pkgs, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      gimp3-with-plugins
    ]
    ++ (with pkgs.gimp3Plugins; [
      gmic
      # fourier
    ]);
}
