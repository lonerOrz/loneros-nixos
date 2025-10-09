# https://github.com/NixOS/nixpkgs/pull/449946
self: super: {
  grpc-tools = super.grpc-tools.overrideAttrs (oldAttrs: rec {
    cmakeFlags = oldAttrs.cmakeFlags or [ ] ++ [
      # Fix configure with newer CMake for the vendored protobuf
      (self.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
    ];
  });
}
