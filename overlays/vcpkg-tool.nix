# https://github.com/NixOS/nixpkgs/pull/462158
self: super: {

  vcpkg-tool = super.vcpkg-tool.overrideAttrs (oldAttrs: rec {
    buildInputs = builtins.filter (dep: dep != super.fmt) (oldAttrs.buildInputs or [ ]) ++ [
      super.fmt_11
    ];
  });
}
