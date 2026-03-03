{ pkgs }:

let
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

      modPath =
        if !builtins.isFunction fnPath && builtins.pathExists (fnPath + "/default.nix") then
          fnPath + "/default.nix"
        else
          fnPath;

      f = if builtins.isFunction fnPath then fnPath else import modPath;

      fargs = if builtins.isFunction f then builtins.functionArgs f else { };

      injected = builtins.intersectAttrs fargs pkgs;
      allArgs = injected // userArgs;

      missingArgs =
        if builtins.isFunction f then
          let
            provided = builtins.attrNames allArgs;
          in
          builtins.filter (n: !(builtins.elem n provided)) (builtins.attrNames fargs)
        else
          [ ];

    in
    if missingArgs != [ ] then
      throw "callImport: missing arguments ${toString missingArgs}"
    else if builtins.isFunction f then
      f allArgs
    else
      f;

in
{
  callImport = arg: if builtins.isList arg then map callImportSingle arg else callImportSingle arg;
}
