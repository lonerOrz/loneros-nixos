{
  pkgs,
  username,
  ...
}:
{

  #boot.kernelModules = [
  #  "vboxdrv"
  #  "vboxnetadp"
  #  "vboxnetflt"
  #];

  virtualisation.virtualbox = {
    host = {
      enable = true;
      enableExtensionPack = true;
      # 下面两个只能开一个
      enableKvm = true;
      addNetworkInterface = false;
      #headless = true;
    };
    guest = {
      enable = true;
      clipboard = true;
      dragAndDrop = true;
      seamless = true;
    };
  };
  users.extraGroups.vboxusers.members = [ "${username}" ];
}
