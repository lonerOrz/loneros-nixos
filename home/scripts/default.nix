{pkgs, ...}:
  let
    maxfetch = pkgs.writeScriptBin "maxfetch" (builtins.readFile ./maxfetch.sh);
    shutdown = pkgs.writeScriptBin "shutdown" (builtins.readFile ./shutdown.sh);
in {
  home.packages = with pkgs; [
    maxfetch
    shutdown
    fuzzel
  ];
}
