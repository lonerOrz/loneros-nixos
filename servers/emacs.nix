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
    package = pkgs.emacs-pgtk;
    startWithGraphical = false;
    # defaultEditor = true;
  };
}
