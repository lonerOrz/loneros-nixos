final: prev: {
  pamixer = prev.pamixer.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or [ ]) ++ [ "-std=c++17" ];
  });
}
