final: prev: {
  scx_git = {
    rustscheds = prev.scx_git.rustscheds.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ./fix_dotest.patch ];
    });
    # 其他子包保持不变
    cscheds = prev.scx_git.cscheds;
    full = prev.scx_git.full;
    recurseForDerivations = true;
  };
}
