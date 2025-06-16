{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rfc-style;
        };
        programs.shfmt.enable = true;
        programs.just.enable = true;
        programs.prettier.enable = true;
      };
    };
}
