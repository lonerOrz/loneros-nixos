{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.writeScriptBin "sounds" (builtins.readFile ./sounds.sh))
    (pkgs.writeScriptBin "screenshot" (builtins.readFile ./screenshot.sh))
    (pkgs.writeScriptBin "logout" (builtins.readFile ./logout.sh))
    (pkgs.writeScriptBin "uptimes" (builtins.readFile ./uptimes.sh))
  ];
}
