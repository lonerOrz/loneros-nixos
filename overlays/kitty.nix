# https://github.com/NixOS/nixpkgs/pull/446833
self: super: {
  kitty = super.kitty.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      # 修复 fish >= 4.1 的测试失败
      (super.fetchpatch {
        url = "https://github.com/kovidgoyal/kitty/commit/2f991691f9dca291c52bd619c800d3c2f3eb0d66.patch";
        hash = "sha256-LIQz3e2qgiwpsMd5EbEcvd7ePEEPJvIH4NmNpxydQiU=";
      })
    ];
  });
}
