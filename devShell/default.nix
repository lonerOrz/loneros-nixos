{
  pkgs,
  ...
}:

let
  # Modules requiring unfree support
  unfreeModules = [ "cuda" ];

  # pkgs instance with unfree packages allowed
  pkgs-unfree = import pkgs.path {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  modules = {
    default = [
      "node"
      "python"
      "c"
      "rust"
      "lua"
      "go"
    ];
    dev = [
      "node"
      "python"
    ];
    node = [ "node" ];
    python = [ "python" ];
    rust = [ "rust" ];
    lua = [ "lua" ];
    go = [ "go" ];
    c = [ "c" ];
    dotnet = [ "dotnet" ];
    cuda = [ "cuda" ];
    python-cuda = [
      "python"
      "cuda"
    ];
  };

  # Check if module list contains any unfree modules
  needsUnfree = modList: builtins.any (m: builtins.elem m modList) unfreeModules;

  loadModules =
    moduleList: pkgs':
    let
      imported = map (name: import ./${name}.nix { pkgs = pkgs'; }) moduleList;
      mergeList = attr:
        pkgs.lib.unique (pkgs.lib.flatten (map (m: m.${attr} or [ ]) imported));
    in
    {
      packages = mergeList "packages";
      nativeBuildInputs = mergeList "nativeBuildInputs";
      env = builtins.foldl' (acc: m: acc // (m.env or { })) { } imported;
      shellHook = builtins.concatStringsSep "\n" (
        pkgs.lib.filter (h: h != "") (map (m: m.shellHook or "") imported)
      );
    };

  # Build shells, using pkgs-unfree for modules that need it
  shells = builtins.mapAttrs (
    name: mods: loadModules mods (if needsUnfree mods then pkgs-unfree else pkgs)
  ) modules;

in

builtins.mapAttrs (
  name: s:
  pkgs.mkShell {
    buildInputs = s.packages;
    nativeBuildInputs = s.nativeBuildInputs;

    shellHook = ''
      ${s.shellHook}

      # Append env variables
      ${builtins.concatStringsSep "\n" (
        map (k: ''
          if [ -n "''${${k}}" ]; then
            export ${k}="${pkgs.lib.escapeShellArg s.env.${k}}:''${${k}}"
          else
            export ${k}="${pkgs.lib.escapeShellArg s.env.${k}}"
          fi
        '') (builtins.attrNames s.env)
      )}

      echo "✅ ${name} DevShell ready"
    '';
  }
) shells
