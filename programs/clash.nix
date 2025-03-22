{
  pkgs,
  ...
}:
{
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev; # or clash-nyanpasu (is break!!!)
    autoStart = true;
  };
}
