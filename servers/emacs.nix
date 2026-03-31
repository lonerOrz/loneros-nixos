{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    symbola
  ];
  services.emacs = {
    enable = true;
    startWithGraphical = false;
    # defaultEditor = true;
  };
}
