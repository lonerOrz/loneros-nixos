{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
let
  cfg = config.drivers.nvidia;

  # If you start experiencing lag and FPS drops in games or programs like Blender on stable NixOS
  # when using the Hyprland flake, it is most likely a mesa version mismatch between your system and Hyprland.
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # https://github.com/NixOS/nixpkgs/pull/412157
  gpl_symbols_linux_615_patch = pkgs.fetchpatch {
    url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
    hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
    stripLen = 1;
    extraPrefix = "kernel/";
  };

  nvType = "stable"; # latest beta stable
  nvidiaPackage =
    if config.boot.kernelPackages.nvidiaPackages."${nvType}".version == "570.153.02" then
      config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "575.57.08";
        sha256_64bit = "sha256-KqcB2sGAp7IKbleMzNkB3tjUTlfWBYDwj50o3R//xvI=";
        sha256_aarch64 = "sha256-VJ5z5PdAL2YnXuZltuOirl179XKWt0O4JNcT8gUgO98=";
        openSha256 = "sha256-DOJw73sjhQoy+5R0GHGnUddE6xaXb/z/Ihq3BKBf+lg=";
        settingsSha256 = "sha256-AIeeDXFEo9VEKCgXnY3QvrW5iWZeIVg4LBCeRtMs5Io=";
        persistencedSha256 = "sha256-Len7Va4HYp5r3wMpAhL4VsPu5S0JOshPFywbO7vYnGo=";

        patches = [ gpl_symbols_linux_615_patch ];
      }
    else
      config.boot.kernelPackages.nvidiaPackages."${nvType}";
in
{
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      package = pkgs.mesa;
      enable32Bit = true;
      package32 = pkgs.pkgsi686Linux.mesa;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
        vdpauinfo
        libva
        libva-utils

        intel-media-driver # Intel GPU 视频解码驱动（VA-API，适用于 6 代 Skylake 及更新型号）
        intel-ocl # Intel OpenCL 驱动（用于 AI 计算、Blender 渲染等）
        libGL # 用于仲裁多个供应商之间的 OpenGL API 调用
      ];
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos
    ];

    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      #dynamicBoost.enable = true; # Dynamic Boost

      nvidiaPersistenced = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.

      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = nvidiaPackage;
    };
  };
}
