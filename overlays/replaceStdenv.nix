# done https://github.com/NixOS/nixpkgs/pull/481399
final: prev: {
  config = (prev.config or { }) // {
    replaceStdenv =
      let
        old = (prev.config or { }).replaceStdenv or null;
      in
      if builtins.isFunction old then old else ({ pkgs }: pkgs.stdenv);
  };
}
