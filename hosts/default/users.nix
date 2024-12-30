{
  pkgs,
  username,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername;
in
{
  users = {
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "video"
        "input"
        "audio"
      ];

      # define user packages here
      packages = with pkgs; [
      ];
    };

    defaultUserShell = pkgs.zsh;
  };

  import = [
    ../../programs/fcitx5.nix
  ];

  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    fzf
    yazi
  ];

  programs = {
    # 在此添加缺失的动态库（这些库会对未打包的程序生效）
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        glibc
        icu
      ];
    };
    # Zsh configuration
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "xiong-chiamiov-plus";
      };

      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      promptInit = ''
        fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

        #pokemon colorscripts like. Make sure to install krabby package
        #krabby random --no-mega --no-gmax --no-regional --no-title -s;

        source <(fzf --zsh);
        HISTFILE=~/.zsh_history;
        HISTSIZE=10000;
        SAVEHIST=10000;
        setopt appendhistory;
      '';
    };
  };
}
