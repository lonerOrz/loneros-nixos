{ pkgs, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      gimp
    ]
    ++ (with pkgs.gimpPlugins; [
      gmic
      # fourier
    ]);
}
