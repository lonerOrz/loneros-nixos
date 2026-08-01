{ config, ... }:

{
  name = "k3s";

  enable = config.cluster.k3s.enable or false;

  secrets = {
    "k3s/token" = {
      mode = "0400";
    };
    "k3s/certificate-authority-data" = {
      mode = "0600";
    };
    "k3s/client-certificate-data" = {
      mode = "0600";
    };
    "k3s/client-key-data" = {
      mode = "0600";
    };
  };
}
