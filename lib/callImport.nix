{ pkgs }:

let
  # 处理单个模块
  callImportSingle =
    arg:
    let
      params =
        if builtins.isAttrs arg then
          arg
        else
          {
            fn = arg;
            args = { };
          };
      fnPath = params.fn;
      userArgs = params.args or { };
      modPath = if builtins.pathExists "${fnPath}/default.nix" then "${fnPath}/default.nix" else fnPath;
      f = if builtins.isFunction modPath then modPath else import modPath;
      fargs = if builtins.isFunction f then builtins.functionArgs f else { };
      allArgs = if builtins.isFunction f then builtins.intersectAttrs fargs pkgs // userArgs else { };
      missingArgs =
        if builtins.isFunction f then
          let
            providedNames = builtins.attrNames allArgs;
          in
          builtins.filter (name: !(builtins.elem name providedNames)) (builtins.attrNames fargs)
        else
          [ ];
      result =
        if builtins.isFunction f then
          f allArgs
        else
          {
            path = modPath;
            config = userArgs;
          };
    in
    if missingArgs != [ ] then
      throw "callImport: missing arguments ${builtins.toString missingArgs}"
    else
      result;

in
{
  callImport = arg: if builtins.isList arg then map callImportSingle arg else callImportSingle arg;
}
