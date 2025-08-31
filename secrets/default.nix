{
  pkgs,
  config,
  inputs,
  username,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    sops
  ];

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  # sops.defaultSopsFile = "/home/${username}/loneros-nixos/secrets/secrets.yaml";
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  # This is the actual specification of the secrets.
  sops.secrets."mihomo/subscription1" = {
    owner = "root";
    mode = "0600";
  };
  sops.secrets."mihomo/secret" = {
    owner = "root";
    mode = "0600";
  };
  sops.secrets."myservice/my_subdir/my_secret" = {
    mode = "0600";
  };
  sops.secrets."loneros/loner/password" = {
    # neededForUsers = true;
    owner = config.users.users.loner.name;
    mode = "0600";
  };
  # sops-nix 必须在 NixOS 创建用户后运行（为了指定哪些用户拥有 secret）。
  # 这意味着无法设置为 users.users.<name>.hashedPasswordFile sops-nix 管理的任何密钥。
  # 要解决此问题，可以在 secret 中设置 neededForUsers = true。
  # 这将导致 Secret 在 NixOS 创建用户之前被解密为 /run/secrets-for-users，
  # 而不是 /run/secrets。由于尚未创建用户，因此无法为这些密钥设置所有者。
  sops.secrets."remote-vm/test/password" = {
    neededForUsers = true;
    mode = "0600";
  };
}
