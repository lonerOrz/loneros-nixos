{pkgs, ...}:
  let
    maxfetch = pkgs.writeScriptBin "maxfetch" (builtins.readFile ./maxfetch.sh);
    shutdown = pkgs.writeScriptBin "shutdown" (builtins.readFile ./shutdown.sh);
    ascii = pkgs.writeScriptBin "ascii" (builtins.readFile ./ascii.sh);
in {
  home.packages = with pkgs; [
    maxfetch
    shutdown
    ascii
  ];
}
