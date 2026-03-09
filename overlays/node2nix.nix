# done https://github.com/NixOS/nixpkgs/pull/498077
self: super: {
  node2nix = super.node2nix.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ super.nodejs ];
  });
}
