{
  services.gnome = {
    gnome-keyring.enable = true; # 用于存储和管理密码、密钥、证书等敏感数据的工具
    gcr-ssh-agent.enable = true;

    evolution-data-server.enable = true;
    gnome-online-accounts.enable = true;

    glib-networking.enable = true;
  };
}
