# https://github.com/NixOS/nixpkgs/pull/462158
self: super: {

  vcpkg-tool = super.vcpkg-tool.overrideAttrs (oldAttrs: rec {
    # 生成新的 buildInputs：去掉旧 fmt，加入 fmt11
    buildInputs = builtins.filter (dep: dep != super.fmt) (oldAttrs.buildInputs or [ ]) ++ [
      super.fmt_11
    ];
  });
}
