{
  inputs,
  ...
}:

{
  imports = [ inputs.aagl.nixosModules.default ];
  nix.settings = inputs.aagl.nixConfig; # Set up Cachix
  programs.sleepy-launcher.enable = true;
}
