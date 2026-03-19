{
  pkgs,
  ...
}:

let
  unfreeModules = [ "cuda" ];

  pkgs-unfree = import pkgs.path {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  shells = {
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

  needsUnfree = modList: builtins.any (m: builtins.elem m modList) unfreeModules;

  loadModule = name: pkgs': import ./${name}.nix { pkgs = pkgs'; };

  buildShell =
    name: modList: pkgs':
    let
      customFile = ./${name}.nix;
      hasCustom = builtins.pathExists customFile;
      modules = map (m: loadModule m pkgs') modList;
      custom = if hasCustom then import customFile { pkgs = pkgs'; } else { };
    in
    pkgs.mkShell {
      inputsFrom = modules ++ (custom.inputsFrom or [ ]);
      buildInputs = custom.packages or [ ];
      nativeBuildInputs = custom.nativeBuildInputs or [ ];
      env = custom.env or { };
      shellHook = custom.shellHook or "";
    };

in

builtins.mapAttrs (
  name: mods: buildShell name mods (if needsUnfree mods then pkgs-unfree else pkgs)
) shells
