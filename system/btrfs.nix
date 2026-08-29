{
  pkgs,
  ...
}:

{
  imports = [
    ../modules/btrfs-auto-scrub.nix
    ../modules/btrfs-auto-balance.nix
  ];

  environment.systemPackages = with pkgs; [
    btrfs-progs # Btrfs 文件系统工具
  ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [
      "/"
    ];
    interval = "monthly";
    limit = "25M";
  };

  services.btrfs.autoBalance = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "weekly";
    dataUsageThreshold = 0.75;
    metadataUsageThreshold = 0.80;
    dusage = 60;
    metadataUsage = 80;
  };
}
