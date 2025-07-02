{ pkgs, ... }:
{
  security.sudo-rs = {
    enable = true;
    package = pkgs.sudo-rs;
  };
}
