{ 
  config,
  ...
}:
{
  catppuccin = {
    #enable = true;
    flavor = "mocha";

    obs.enable = true;
    btop.enable = true;
    zed.enable = true;
  };
}
