{
  inputs,
  username,
  host,
  ...
}:

let
  containerMap = {
    loneros = [
      ./aria2.nix
      ./filegator.nix
      ./glance.nix
      ./mysql8.nix
      ./peerbanhelper.nix
      ./qinglong.nix
      ./reader.nix
      ./redis.nix
      ./uptime.nix
    ];

    loneros-wsl = [
      ./hermes.nix
    ];
  };

  targetContainers = containerMap.${host} or [ ];
in
{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
  ]
  ++ targetContainers;

  # user 需要显示设置 uid
  users.users.${username} = {
    # required for auto start before user login
    linger = true;
    # required for rootless container with multiple users
    autoSubUidGidRange = true;
  };

  virtualisation.quadlet = {
    autoUpdate = {
      enable = true;
      calendar = "daily";
    };
  };
}
