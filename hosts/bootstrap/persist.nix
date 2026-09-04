{
  inputs,
  lib,
  pkgs,
  username,
  ...
}:

{
  imports = [
    inputs.preservation.nixosModules.default
  ];

  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    pkgs.ncdu
  ];

  preservation = {
    enable = true;

    preserveAt."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"
        "/etc/nix/inputs"
        # "/etc/agenix" # age 密钥

        # 系统核心状态
        "/var/lib/nixos"
        "/var/lib/systemd"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }

        # 容器
        # "/var/lib/docker"
        # "/var/lib/cni"
        # "/var/lib/containers"

        # flatpak
        # "/var/lib/flatpak"

        # 虚拟化
        # "/var/lib/incus"
        # "/var/lib/libvirt"
        # "/var/lib/lxc"
        # "/var/lib/lxd"
        # "/var/lib/qemu"
        # "/var/lib/waydroid"

        # 网络
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/var/lib/iwd"
        # "/var/lib/tailscale"
      ];

      files = [
        # 自动生成的机器 ID
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];

      # 用户目录持久化
      users.${username} = {
        commonMountOptions = [
          "x-gvfs-hide" # 避免在文件管理器中显示为外部挂载卷
        ];
        directories = [
          # XDG 目录
          "Desktop"
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"

          # 缓存避开 tmpfs 占用内存
          ".cache"

          # loneros flake
          "loneros-nixos"

          # Nix
          ".local/state/nix/profiles"
          ".local/share/nix"

          # IDE 与编辑器
          ".config/zed"
          ".local/share/zed"

          # AI Agent 与 LLM 开发工具
          ".config/opencode"
          ".local/share/opencode"
          ".local/state/opencode"
          ".context7"

          # Neovim 插件与状态
          ".local/share/nvim"
          ".local/state/nvim"

          # 高敏感目录设为 0700 权限
          {
            directory = ".config/gh";
            mode = "0700";
          }

          # 语言包管理器缓存
          ".npm"
          ".config/go"
          ".cargo"
          ".local/bin"
          ".local/share/uv" # Python uv

          # 凭证、密钥与安全
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".pki";
            mode = "0700";
          }
          {
            directory = ".local/share/password-store";
            mode = "0700";
          }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          } # GNOME 密钥环

          # 游戏与媒体
          ".steam"
          ".local/share/Steam"

          # 浏览器
          ".mozilla"
          ".config/chromium"

          # CLI 工具历史
          ".local/share/atuin"
          ".local/share/zoxide"
          ".local/share/direnv"

          # 应用沙盒
          ".local/share/containers"
          ".local/share/flatpak"
          {
            directory = ".var";
            mode = "0700";
          } # Flatpak/Nixpak 应用数据

          # 杂项
          ".config/nushell"
        ];

        files = [
          {
            file = ".config/zoom.conf";
            how = "symlink";
          }
          {
            file = ".claude.json";
            how = "bindmount";
          }
        ];
      };
    };
  };

  # 使用 systemd-tmpfiles 预先在 tmpfs /home 下构建好正确的用户父目录权限，
  # 避免因为挂载路径顶层由 root 创建而导致普通用户无写入权限问题 [1.1.2]
  systemd.tmpfiles.settings.preservation =
    let
      permission = {
        user = username;
        group = lib.mkForce username;
        mode = lib.mkForce "0750";
      };
    in
    {
      "/home/${username}/.config".d = permission;
      "/home/${username}/.local".d = permission;
      "/home/${username}/.local/share".d = permission;
      "/home/${username}/.local/state".d = permission;
      "/home/${username}/.local/state/nix".d = permission;
      "/home/${username}/.terraform.d".d = permission;
    };

  # 抑制默认的 machine-id 提交服务
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # 将生成的 machine-id 提交至持久化位置 /persistent
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };

  # 在 initrd 阶段同样屏蔽此服务以避免报错 [3.1.4, 3.4.6]
  boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
}
