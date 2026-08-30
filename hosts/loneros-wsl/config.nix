{
  pkgs,
  inputs,
  stable,
  username,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  inherit (import ./variables.nix) keyboardLayout;
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default

    ./wsl.nix
    ./users.nix
    ./dev.nix
    ./system.nix
    ./nix.nix

    # virtualisation
    ../../virtualisation

    # system
    ../../system/timezone.nix
    ../../system/fonts.nix
    ../../system/doc.nix
    ../../system/security.nix

    # programs
    ../../programs/git.nix
    ../../programs/fcitx5.nix
    ../../programs/direnv.nix
    ../../programs/nvim.nix
    ../../programs/nh.nix

    # servers
    ../../servers/atuin.nix
    # ../../servers/emacs.nix
    # ../../servers/ollama.nix
  ];

  # Services to start
  services = {
    # 禁用 X Server
    xserver = {
      enable = false;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };

    gvfs.enable = true; # 提供虚拟文件系统，允许你通过统一的接口访问网络和远程文件系统
    tumbler.enable = true; # 生成文件缩略图的后台服务
    # https://github.com/nix-community/NixOS-WSL/issues/846
    envfs.enable = false; # 许通过 /env 路径访问环境变量
    dbus.enable = true; # 进程间通信（IPC）的系统总线

    libinput.enable = true; # 输入设备驱动
    fwupd.enable = true; # 管理和更新硬件固件
    upower.enable = true; # 管理电池、能源和电源管理的守护进程

    # 用于文件同步的工具
    # syncthing = {
    #   enable = false;
    #   user = "${username}";
    #   dataDir = "/home/${username}";
    #   configDir = "/home/${username}/.config/syncthing";
    # };
  };

  # For Electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11";
}
