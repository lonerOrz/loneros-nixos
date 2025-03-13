{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.writeScriptBin "maxfetch" (builtins.readFile ./maxfetch.sh))
    (pkgs.writeScriptBin "shut" (builtins.readFile ./shutdown.sh))
    (pkgs.writeScriptBin "ascii" (builtins.readFile ./ascii.sh))
    (pkgs.writeScriptBin "showkey" (builtins.readFile ./showkey.sh))
    (pkgs.writeScriptBin "mkimage" (builtins.readFile ./mkimage.sh))
    (pkgs.writeScriptBin "v2g" (builtins.readFile ./v2g.sh))
    (pkgs.writeScriptBin "vmerge" (builtins.readFile ./vmerge.sh))
    (pkgs.writeScriptBin "ts" (builtins.readFile ./ts.sh))
    (pkgs.writeScriptBin "yt" (builtins.readFile ./yt.sh))
  ];
}
