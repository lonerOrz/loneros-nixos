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
    package = pkgs.emacs31-nox;
    startWithGraphical = false;
    # defaultEditor = true;
  };
}
