{
  lib,
  pkgs,
  inputs,
  config,
  host,
  username,
  ...
}:

let
  providers = [
    ./modules/cloudflared.nix
    ./modules/forgejo.nix
    ./modules/k3s.nix
    ./modules/mihomo.nix
  ];

  # 解析 Provider 并注入 host 路径及默认属性
  loadProvider =
    providerFile:
    let
      providerFn = import providerFile;
      provider =
        if builtins.isFunction providerFn then
          providerFn {
            inherit
              config
              lib
              pkgs
              host
              username
              ;
          }
        else
          providerFn;

      sopsPath = ./${host} + "/${provider.name}.yaml";
      hasSopsFile = builtins.pathExists sopsPath;

      shouldEnable = (provider.enable or true) && hasSopsFile;
    in
    lib.optionalAttrs shouldEnable (
      lib.mapAttrs (
        _: secretOpts:
        {
          sopsFile = sopsPath;
          mode = secretOpts.mode or "0600";
          owner = secretOpts.owner or "root";
          group = secretOpts.group or "root";
        }
        // (removeAttrs secretOpts [
          "mode"
          "owner"
          "group"
        ])
      ) provider.secrets
    );

  # 主机基础密码 (${host}/secrets.yaml)
  hostBaseSecretPath = ./${host}/secrets.yaml;
  hostBaseSecrets = lib.optionalAttrs (builtins.pathExists hostBaseSecretPath) {
    "${host}/${username}/password" = {
      sopsFile = hostBaseSecretPath;
      mode = "0600";
      owner = config.users.users.${username}.name;
      group = "root";
    };
  };

in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    sops
  ];

  # This will add secrets.yaml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  sops = {
    defaultSopsFile = ./${host}/secrets.yaml;
    defaultSopsFormat = "yaml";
    # 创建 sops-install-secrets.service systemd 服务
    useSystemdActivation = true;
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];
    # This is using an age key that is expected to already be in the filesystem
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt"; # 更改位置需要使用 SOPS_AGE_KEY_FILE 环境变量
    # This will generate a new key if the key specified above does not exist
    age.generateKey = true;
  };

  sops.secrets = lib.mkMerge ([ hostBaseSecrets ] ++ (map loadProvider providers));
}
