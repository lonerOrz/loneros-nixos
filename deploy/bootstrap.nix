{
  inputs,
  nixosConfigurations,
  hostConfig,
  nodeName,
}:
{
  hostname = "192.168.122.88";
  sshUser = hostConfig.username;
  # This is an optional list of arguments that will be passed to SSH.
  sshOpts = [
    "-p"
    "22"
  ];
  # Fast connection to the node. If this is true, copy the whole closure instead of letting the node substitute.
  fastConnection = true;
  # Whether to enable interactive sudo (password based sudo). Useful when using non-root sshUsers.
  interactiveSudo = true;
  # If the previous profile should be re-activated if activation fails.
  autoRollback = true;
  # See the earlier section about Magic Rollback for more information.
  magicRollback = true;

  profiles.system = {
    user = hostConfig.username;
    path = inputs.deploy-rs.lib.${hostConfig.system}.activate.nixos nixosConfigurations.${nodeName};
  };
}
