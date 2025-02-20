{ username
, host
, ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) gitUsername gitEmail;
in
{
  programs = {
    # Configure Git
    git = {
      enable = true;
      userName = "${gitUsername}";
      userEmail = "${gitEmail}";
      # alias = { co = "checkout"; };
      extraConfig = {
        # Sign all commits using ssh key
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "/home/${username}/.ssh/id_rsa.pub";
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
