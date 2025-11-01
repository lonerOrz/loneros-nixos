{ pkgs, ... }:

let
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
  };

  loadModules =
    moduleList:
    let
      imported = map (name: import ./${name}.nix { inherit pkgs; }) moduleList;
    in
    {
      packages = pkgs.lib.flatten (map (m: m.packages or [ ]) imported);
      nativeBuildInputs = pkgs.lib.flatten (map (m: m.nativeBuildInputs or [ ]) imported);
      propagatedBuildInputs = pkgs.lib.flatten (map (m: m.propagatedBuildInputs or [ ]) imported);
      propagatedNativeBuildInputs = pkgs.lib.flatten (
        map (m: m.propagatedNativeBuildInputs or [ ]) imported
      );
      inputsFrom = pkgs.lib.flatten (map (m: m.inputsFrom or [ ]) imported);
      env = builtins.foldl' (acc: m: acc // (m.env or { })) { } imported;
      shellHook = builtins.concatStringsSep "\n" (map (m: m.shellHook or "") imported);
    };

  shells = builtins.mapAttrs (_name: mods: loadModules mods) modules;

in
builtins.mapAttrs (
  name: s:
  pkgs.mkShell {
    buildInputs = s.packages;
    nativeBuildInputs = s.nativeBuildInputs;
    propagatedBuildInputs = s.propagatedBuildInputs;
    propagatedNativeBuildInputs = s.propagatedNativeBuildInputs;
    inputsFrom = s.inputsFrom;

    shellHook = ''
      ${s.shellHook}

      # 保留旧值：让所有 env 变量追加到现有的环境中
      ${builtins.concatStringsSep "\n" (
        map (k: ''
          if [ -n "${"$" + k}" ]; then
            export ${k}="${s.env.${k}}:${"$" + k}"
          else
            export ${k}="${s.env.${k}}"
          fi
        '') (builtins.attrNames s.env)
      )}

      echo "✅ ${name} DevShell ready"
    '';
  }
) shells
