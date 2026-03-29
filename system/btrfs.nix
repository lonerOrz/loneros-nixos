{
  imports = [
    ../modules/btrfs-auto-scrub.nix
    ../modules/btrfs-auto-balance.nix
  ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [
      "/" # 只需要根挂载点,是同一个 Btrfs FS
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
