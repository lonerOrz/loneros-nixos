{
  host,
  config,
  username,
  ...
}:
{
  sops.templates."kubeconfig.yaml" = {
    owner = "${username}";
    mode = "0600";
    content = ''
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: ${
            config.sops.placeholder."k3s/certificate-authority-data"
          } # base64 encoded CA
          server: https://${host}:6443 # master-ip
        name: default
      contexts:
      - context:
          cluster: default
          user: default
        name: default
      current-context: default
      kind: Config
      users:
      - name: default
        user:
          client-certificate-data: ${
            config.sops.placeholder."k3s/client-certificate-data"
          } # 客户端证书，base64 编码
          client-key-data: ${config.sops.placeholder."k3s/client-key-data"} # 客户端私钥，base64 编码
          token: ${config.sops.placeholder."k3s/token"}
    '';
  };

  cluster.k3s.configPath = config.sops.templates."kubeconfig.yaml".path;

  # systemd.tmpfiles.rules = [
  #   "d /home/${username}/.kube 0700 ${username} users -"
  #   "L ${config.sops.templates."kubeconfig.yaml".path} /home/${username}/.kube/config"
  # ];
}
