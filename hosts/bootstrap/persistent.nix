{
  username,
  ...
}:
{
  # =========================================
  # 持久化配置
  # =========================================
  environment.persistence."/persistent" = {
    enable = true; # 启用持久化
    hideMounts = true; # 在文件管理器隐藏绑定挂载

    # 系统级目录持久化
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];

    # 系统级文件持久化
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_ecdsa_key"
      "/etc/ssh/ssh_host_ed25519_key"
      {
        file = "/nix/keys/secrets.yaml";
        parentDirectory = {
          mode = "0700";
        };
      }
    ];

    # 用户目录持久化
    users.${username} = {
      directories = [
        "Downloads"
        "Documents"
        "Pictures"
        "Music"
        "Videos"
        ".ssh" # SSH keys & authorized_keys
        ".gnupg" # GPG keys
        ".local/share/keyrings"
        ".nixops"
        ".local/share/direnv"
      ];
      files = [
        ".screenrc"
      ];
    };
  };
}
