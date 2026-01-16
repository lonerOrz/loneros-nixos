{
  config,
  host,
  ...
}:
{
  imports = [ ./kubeconfig.nix ];

  cluster.k3s = {
    enable = true;

    role = "server";
    clusterInit = true;

    tokenFile = config.sops.secrets."k3s/token".path;

    node = {
      name = "${host}";
      labels = [ "role=control-plane" ];
    };
  };
}
