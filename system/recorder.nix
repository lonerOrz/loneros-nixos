{
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    gpu-screen-recorder
    slurp
  ];

  security.wrappers = {
    gsr-kms-server = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = lib.getExe' pkgs.gpu-screen-recorder "gsr-kms-server";
    };
  };
}
