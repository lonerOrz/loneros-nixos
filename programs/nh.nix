{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) autoGarbage;
in
{
  programs.nh = {
    enable = true;
    flake = "/home/${username}/loneros-nixos";
    clean = {
      enable = autoGarbage;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };
  # 构建监视
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}
