{
  lib,
  host,
  pkgs,
  config,
  ...
}:
let
  v4l2loopbackPackage =
    if config.boot.kernelPackages.v4l2loopback.version == "0.13.2-6.15.0" then
      # https://github.com/NixOS/nixpkgs/pull/411777
      (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
        version = "0.15.0";
        src = pkgs.fetchFromGitHub {
          owner = "umlaeute";
          repo = "v4l2loopback";
          rev = "v0.15.0";
          sha256 = "sha256-fa3f8GDoQTkPppAysrkA7kHuU5z2P2pqI8dKhuKYh04=";
        };
      }))
    else
      config.boot.kernelPackages.v4l2loopback;
in
{
  # BOOT related stuff
  boot = {
    # Kernel
    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_zen;
    # https://github.com/chaotic-cx/nyx/pull/1176
    kernelPackages = pkgs.linuxPackages_cachyos-lto.cachyOverride { mArch = "NATIVE"; };
    # if nvidia driver broken, try this:
    # .extend (
    #   lpself: lpsuper: {
    #     inherit (pkgs.linuxPackages_cachyos-gcc) evdi nvidiaPackages; # 引入 CachyOS-GCC 的 NVIDIA 和 EVDI 驱动模块
    #   }
    # );

    kernelParams = [
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device" # this is to mask that stupid 1.5 mins systemd bug
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco" # watchdog for AMD
      "modprobe.blacklist=iTCO_wdt" # watchdog for Intel
      "i2c_hid.ignore_duplicate_id=1" # 忽略重复注册的 I2C HID 设备
    ];

    # This is for OBS Virtual Cam Support
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [
      v4l2loopbackPackage
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "btrfs"
        #"hid_cherry"
        #"hid_logitech_hidpp"
        #"hid_logitech_dj"
      ];
      kernelModules = [ ];
    };

    ## BOOT LOADERS: NOT USE ONLY 1. either systemd or grub
    # Bootloader SystemD
    loader.systemd-boot.enable = false;

    loader.efi = {
      efiSysMountPoint = "/boot"; # this is if you have separate /efi partition
      canTouchEfiVariables = true;
    };

    # Bootloader GRUB
    loader.grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      gfxmodeBios = "auto";
      #memtest86.enable = true;
      # useOSProber = true;
      extraGrubInstallArgs = [ "--bootloader-id=${host}" ];
      configurationName = "${host}";
      extraConfig = ''
        insmod kbd
        set keymap=us
      '';
      extraEntries = ''
        menuentry "UEFI Firmware Settings" {
          fwsetup
        }
      '';
    };

    ## -end of BOOTLOADERS----- ##

    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };

    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    # 启动动画
    plymouth.enable = false;
  };
  # GRUB Bootloader theme. Of course you need to enable GRUB above.. duh!
  distro-grub-themes = {
    enable = false;
    theme = "nixos"; # arch-liunx debain deppin gentoo fedora ...
  };
  honkai-railway-grub-theme = {
    enable = true;
    theme = "Huohuo"; # Kafka Huohuo March7th-TheHunt
  };
  # cachyOS kernel 调度规则
  services.scx = {
    enable = true;
    scheduler = "scx_rusty";
    package = pkgs.scx.full;
  };
}
