{
  lib,
  pkgs,
  inputs,
  username,
  ...
}:

let
  mylib = import ../../lib/default.nix {
    inherit lib pkgs;
  };
in
{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
  ]
  ++ mylib.autoImport {
    dir = ./.;
    exclude = [
      ""
    ];
  };

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
