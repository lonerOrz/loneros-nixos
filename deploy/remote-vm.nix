{
  inputs,
  nixosConfigurations,
  hostConfig,
  nodeName,
}:
{
  hostname = "192.168.122.88";
  sshUser = hostConfig.username;
  fastConnection = true;
  interactiveSudo = true;
  profiles.system = {
    user = hostConfig.username;
    path = inputs.deploy-rs.lib.${hostConfig.system}.activate.nixos nixosConfigurations.${nodeName};
  };
}
