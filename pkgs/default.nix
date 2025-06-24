# For export packages
{
  mylib,
  pkgs,
  system,
  ...
}:
{
  mpv-handler = pkgs.callPackage ./mpv-handler.nix { };
  # shijima-qt = pkgs.callPackage ./shijima-qt.nix { };
  # turntable = pkgs.callPackage ./turntable.nix { };
  sddm = pkgs.callPackage ./astronaut-sddm.nix {
    theme = "hyprland_kath";
    # themeConfig={
    #   General = {
    #     HeaderText ="Hi";
    #     Background="/home/${username}/Desktop/wp.png";
    #     FontSize="9.0";
    #   };
    # };
  };
  xdman7 =
    if system == "x86_64-linux" then
      pkgs.callPackage ./xdman7.nix { }
    else
      pkgs.runCommand "xdman7-unavailable" { } ''
        echo "xdman7 is only available on x86_64-linux" > $out
      '';
  test = pkgs.writeText "test-uppercase" (
    let
      upper = mylib.toUpperCase "hello loner";
    in
    upper
  );
}
