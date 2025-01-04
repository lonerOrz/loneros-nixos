{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername gitEmail;
in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
  home.enableNixpkgsReleaseCheck = false;
  programs.home-manager.enable = true;

  imports = [
    #../../programs/home/catppuccin.nix
  ];

  programs = {
    # Install & Configure Git
    git = {
      enable = true;
      userName = "${gitUsername}";
      userEmail = "${gitEmail}";
      # alias = { co = "checkout"; };
      extraConfig = {
        # Sign all commits using ssh key
        # commit.gpgsign = true;
        # gpg.format = "ssh";
        # user.signingkey = "~/.ssh/id_ed25519.pub";

        init.defaultBranch = "main";

        color = {
          ui = "auto";
        };

        push = {
          default = "simple";
        };
      };
    };
  };
}
