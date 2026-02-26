# done https://github.com/NixOS/nixpkgs/pull/491807
final: prev: {
  deno = prev.deno.overrideAttrs (old: {
    cargoTestFlags = [
      "--lib" # unit tests
      "--test=integration_test"

      # Test targets not included here:
      # - node_compat: heavy network usage
      # - specs: custom harness without --skip support
    ];
  });
}
