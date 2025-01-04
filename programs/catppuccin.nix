{ 
  config,
  ...
}:
{
  catppuccin = {
    #enable = true;
    flavor = "mocha";

    tty.enable = true;
    grub.enable = false;
  };
}
