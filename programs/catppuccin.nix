{
  config,
  ...
}:
{
  catppuccin = {
    #enable = true;
    flavor = "mocha";

    tty.enable = true;
    grub.enable = true;
    sddm = {
      enable = true;
      loginBackground = true;
      # background = ""; # Background image to use for the login screen
      font = "Fria Code";
      fontSize = "8";
    };
  };
}
