{
  username,
  host,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) gitUsername gitEmail;
in
{
  programs = {
    # Configure Git
    git = {
      enable = true;
      lfs.enable = true; # Enable Git Large File Storage
      config = {
        user.name = "${gitUsername}";
        user.email = "${gitEmail}";
        # Sign all commits using ssh key
        commit.gpgsign = true;
        gpg.format = "openpgp";
        user.signingkey = "F55E587ECAB5D316";
        init.defaultBranch = "main";
        core.editor = "nvim";
        color.ui = "auto";
        push.default = "simple";
        pull.rebase = true;
      };
    };
  };
}
