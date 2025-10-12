# mbedtls_2 在 drvPath 阶段就被访问，而 overlay 替换是在 derivation 层次，太晚了
# self: super: {
#   openrgb = super.openrgb.overrideAttrs (old: {
#     buildInputs = builtins.map (x: if x == super.mbedtls_2 then self.mbedtls else x) (
#       old.buildInputs or [ ]
#     );
#   });
# }

# https://github.com/NixOS/nixpkgs/pull/450962
self: super: {
  openrgb = super.callPackage ./openrgb.nix { };
}
