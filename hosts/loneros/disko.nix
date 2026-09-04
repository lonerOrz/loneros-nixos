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
      device = "/dev/nvme0n1"; # /dev/sda 或 /dev/nvme0n1
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "boot";
            name = "ESP";
            start = "1M";
            end = "1G";
            type = "EF00"; # EF00 = ESP in GPT
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0177" # File mask: 777-177=600 (owner rw-, group/others ---)
                "dmask=0077" # Directory mask: 777-077=700 (owner rwx, group/others ---)
                "noexec,nosuid,nodev" # Security: no execution, ignore setuid, no device nodes
              ];
            };
          };

          luks = {
            size = "100%";
            label = "luks";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true; # TRIM for SSDs; slightly less secure, better performance
              };
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
