{
  config,
  pkgs,
  username,
  lib,
  ...
}:
let
  dirdot = {
    ".config/xdg-desktop-portal" = "/home/${username}/dotfiles/xdg-desktop-portal";
  };

  filedot = {
    ".config/xdg-desktop-portal" = "/home/${username}/dotfiles/xdg-desktop-portal";
  };

  mkFileRulesFromDir =
    targetPrefix: sourcePath:
    let
      inherit (builtins) readDir attrNames concatLists;
      walk =
        rel: path:
        let
          dir = readDir path;
        in
        concatLists (
          map (
            name:
            let
              subPath = "${path}/${name}";
              relName = if rel == "" then name else "${rel}/${name}";
            in
            if dir.${name} == "directory" then
              walk relName subPath
            else
              [ "L %h/${targetPrefix}/${relName} - - - - ${subPath}" ]
          ) (attrNames dir)
        );
    in
    walk "" sourcePath;

  fileRules = lib.flatten (
    lib.attrsets.mapAttrsToList (name: path: mkFileRulesFromDir name path) filedot
  );

  dirRules = lib.attrsets.mapAttrsToList (name: path: "L %h/${name} - - - - ${path}") dirdot;
in
{
  systemd.user.tmpfiles.users.${username}.rules = fileRules ++ dirRules;
}
