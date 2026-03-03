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
      mergeList = attr: pkgs.lib.flatten (map (m: m.${attr} or [ ]) imported);
    in
    {
      packages = mergeList "packages";
      nativeBuildInputs = mergeList "nativeBuildInputs";
      propagatedBuildInputs = mergeList "propagatedBuildInputs";
      propagatedNativeBuildInputs = mergeList "propagatedNativeBuildInputs";
      inputsFrom = mergeList "inputsFrom";
      env = builtins.foldl' (acc: m: acc // (m.env or { })) { } imported;
      shellHook = builtins.concatStringsSep "\n" (map (m: m.shellHook or "") imported);
    };

  # 调用 loadModules 生成每个分类的属性集
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

      # 将 env 变量追加到现有环境
      ${builtins.concatStringsSep "\n" (
        map (k: ''
          if [ -n "''${${k}}" ]; then
            export ${k}="${s.env.${k}}:''${${k}}"
          else
            export ${k}="${s.env.${k}}"
          fi
        '') (builtins.attrNames s.env)
      )}

      echo "✅ ${name} DevShell ready"
    '';
  }
) shells
