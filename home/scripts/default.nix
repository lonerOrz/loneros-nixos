{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.writeScriptBin "maxfetch" (builtins.readFile ./maxfetch.sh))
    (pkgs.writeScriptBin "shut" (builtins.readFile ./shutdown.sh))
    (pkgs.writeScriptBin "ascii" (builtins.readFile ./ascii.sh))
    (pkgs.writeScriptBin "showkey" (builtins.readFile ./showkey.sh))
  ];
}
