{
  pkgs,
  gitHooks ? null,
  ...
}:

let
  unfreeModules = [
    "cuda"
    "python-cuda"
  ];

  pkgsUnfree = import pkgs.path {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  shells = {
    default = [ "c" ];
    dev = [
      "node"
      "python"
      "c"
    ];
    node = [ "node" ];
    python = [ "python" ];
    rust = [ "rust" ];
    lua = [ "lua" ];
    go = [ "go" ];
    zig = [ "zig" ];
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
      filteredModList = builtins.filter (m: m != name) modList;
      modules = map (m: loadModule m pkgs') filteredModList;
      custom = if hasCustom then loadModule name pkgs' else { };
    in
    pkgs'.mkShell {
      inputsFrom =
        modules
        ++ (custom.inputsFrom or [ ])
        ++ (if hasCustom && custom ? drvPath then [ custom ] else [ ]);

      buildInputs = custom.packages or (custom.buildInputs or [ ]);

      nativeBuildInputs =
        (custom.nativeBuildInputs or [ ]) ++ (if gitHooks != null then gitHooks.enabledPackages else [ ]);

      env = custom.env or { };

      shellHook = ''
        ${if gitHooks != null then gitHooks.shellHook else ""}
        ${custom.shellHook or ""}
      '';
    };

in
builtins.mapAttrs (
  name: mods: buildShell name mods (if needsUnfree mods then pkgsUnfree else pkgs)
) shells
