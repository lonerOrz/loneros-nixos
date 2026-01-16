{
  lib,
  pkgs,
  inputs,
  config,
  host,
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
  sops.defaultSopsFile = ./${host}/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt"; # 更改位置需要使用 SOPS_AGE_KEY_FILE 环境变量
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  # This is the actual specification of the secrets.
  sops.secrets =
    let
      mkMihomo = mode: {
        sopsFile = ./${host}/mihomo.yaml;
        owner = "root";
        inherit mode;
      };

      mkCloudflared = mode: {
        sopsFile = ./${host}/cloudflared.yaml;
        owner = "root";
        inherit mode;
      };

      mkK3s = mode: {
        sopsFile = ./${host}/k3s.yaml;
        owner = "root";
        inherit mode;
      };
      # 支持递归展开多层 attrset
      flattenSecrets =
        sep: prefix: attrs:
        builtins.foldl' (
          acc: key:
          let
            value = attrs.${key};
            newPrefix = if prefix == "" then key else "${prefix}${sep}${key}";
            isLeafAttrset =
              builtins.isAttrs value && builtins.all (k: !builtins.isAttrs value.${k}) (builtins.attrNames value);
          in
          if builtins.isAttrs value && !isLeafAttrset then
            acc // flattenSecrets sep newPrefix value
          else
            acc // { "${newPrefix}" = value; }
        ) { } (builtins.attrNames attrs);

      secretsNested =
        lib.optionalAttrs (config.services.cloudflared.enable or false) {
          cloudflared = {
            cert_pem = mkCloudflared "0600";
            tunnel_json = mkCloudflared "0600";
          };
        }
        // lib.optionalAttrs (config.services.mihomo.enable or false) {
          mihomo = {
            subscription1 = mkMihomo "0600";
            secret = mkMihomo "0600";
          };
        }
        // lib.optionalAttrs (config.cluster.k3s.enable or false) {
          k3s = {
            token = mkK3s "0400";
            certificate-authority-data = mkK3s "0600";
            client-certificate-data = mkK3s "0600";
            client-key-data = mkK3s "0600";
          };
        }
        // {
          ${host} = {
            ${username} = {
              password = {
                owner = config.users.users.${username}.name;
                mode = "0600";
              };
            };
          };
        };

    in
    flattenSecrets "/" "" secretsNested;
}
