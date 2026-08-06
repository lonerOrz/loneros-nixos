{
  inputs,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "relatime"
        "mode=755"
        "nosuid"
        "nodev"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/sda"; # CHANGE-ME
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "boot";
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "umask=0077"
              ];
            };
          };

          luks = {
            size = "100%";
            label = "luks";
            content = {
              type = "luks";
              name = "cryptroot";
              extraOpenArgs = [
                "--allow-discards"
                "--perf-no_read_workqueue"
                "--perf-no_write_workqueue"
              ];
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=@home"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=@nix"
                      "compress=zstd:1"
                      "noatime"
                    ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=@persist"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=@log"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # 保证持久化卷与日志卷在系统启动早期被挂载
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
