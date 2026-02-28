# wait https://github.com/NixOS/nixpkgs/pull/429146
self: super: {
  ncmpcpp = super.ncmpcpp.overrideAttrs (
    old:
    let
      oldBInputs = old.buildInputs or [ ];
      oldCFlags = old.configureFlags or [ ];
    in
    {
      buildInputs = (builtins.filter (dep: dep != super.boost) oldBInputs) ++ [ super.boost187 ];

      configureFlags = (builtins.filter (flag: builtins.match ".*boost.*" flag == null) oldCFlags) ++ [
        (super.lib.withFeatureAs true "boost" super.boost187.dev)
      ];
    }
  );
}
