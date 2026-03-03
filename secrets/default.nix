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
  mylib = import ../lib/default.nix { inherit lib pkgs; };
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

  # This is the actual specification of the secrets.
  sops.secrets =
    let
      # 基础构造函数
      # args@{ mode, owner ? "root", group ? "root", ... } 允许额外字段自动透传
      mkSecretFile =
        file:
        args@{
          mode,
          owner ? "root",
          group ? "root",
          ...
        }:
        {
          sopsFile = file;
          inherit mode owner group;
        };

      mkMihomo = args: mkSecretFile ./${host}/mihomo.yaml args;
      mkCloudflared = args: mkSecretFile ./${host}/cloudflared.yaml args;
      mkK3s = args: mkSecretFile ./${host}/k3s.yaml args;

      # 批量处理：将 { name = { mode = "..."; }; ... } 转为 { name = mkXxx { mode = "..."; }; ... }
      mkBatch = fn: lib.mapAttrs (_: fn);

      secretsNested =
        lib.optionalAttrs (config.services.cloudflared.enable or false) {
          cloudflared = mkBatch mkCloudflared {
            cert_pem = {
              mode = "0600";
            };
            tunnel_json = {
              mode = "0600";
            };
          };
        }
        // lib.optionalAttrs (config.services.mihomo.enable or false) {
          mihomo = mkBatch mkMihomo {
            subscription1 = {
              mode = "0600";
              format = "yaml";
            };
            secret = {
              mode = "0600";
            };
          };
        }
        // lib.optionalAttrs (config.cluster.k3s.enable or false) {
          k3s = mkBatch mkK3s {
            token = {
              mode = "0400";
            };
            certificate-authority-data = {
              mode = "0600";
            };
            client-certificate-data = {
              mode = "0600";
            };
            client-key-data = {
              mode = "0600";
            };
          };
        }
        // {
          ${host} = {
            ${username} = {
              password = {
                mode = "0600";
                owner = config.users.users.${username}.name;
              };
            };
          };
        };

    in
    mylib.flattenAttrset "/" secretsNested;
}
