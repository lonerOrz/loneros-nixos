{
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    gpu-screen-recorder
    wl-clipboard
    libnotify
    slurp
  ];

  security.wrappers = {
    gpu-screen-recorder = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = lib.getExe pkgs.gpu-screen-recorder;
    };
    gsr-kms-server = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    };
  };
}
