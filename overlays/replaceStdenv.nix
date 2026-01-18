final: prev: {
  config = (prev.config or { }) // {
    replaceStdenv =
      let
        old = (prev.config or { }).replaceStdenv or null;
      in
      if builtins.isFunction old then old else ({ pkgs }: pkgs.stdenv);
  };
}
