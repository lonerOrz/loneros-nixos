{
  lib,
  config,
  host,
  ...
}:
let
  k3sEnabled = false;
in
{
  imports = [ ] ++ lib.optionals k3sEnabled [ ./kubeconfig.nix ];

  cluster.k3s = {
    enable = k3sEnabled;

    role = "server";
    clusterInit = true;

    tokenFile = config.sops.secrets."k3s/token".path;

    node = {
      name = "${host}";
      labels = [ "role=control-plane" ];
    };
  };
}
