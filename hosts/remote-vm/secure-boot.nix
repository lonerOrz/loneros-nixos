{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.boot.loader.secureBoot or { };
in
{
  options.boot.loader.secureBoot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "启用 GRUB + Secure Boot 支持（shim + sbctl），自动签名 GRUB EFI 和最新内核/Initrd";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      sbctl
      shim
    ];

    system.activationScripts.secureboot-shim = {
      text = ''
        echo "=== Secure Boot 自动签名 (shim + sbctl) ==="

        if ! command -v sbctl >/dev/null; then
          echo "sbctl 未安装，无法签名"
          exit 0
        fi

        ESP_DIR="/boot/efi"
        SHIM_SRC="${pkgs.shim}/boot/efi/EFI/BOOT/shimx64.efi"

        # 拷贝 shim
        if [ -f "$SHIM_SRC" ]; then
          echo "拷贝 shim 到 $ESP_DIR/EFI/BOOT/BOOTX64.EFI"
          mkdir -p "$ESP_DIR/EFI/BOOT"
          cp -f "$SHIM_SRC" "$ESP_DIR/EFI/BOOT/BOOTX64.EFI"
        fi

        # 签 GRUB EFI
        GRUB_EFI="$ESP_DIR/EFI/nixos/grubx64.efi"
        if [ -f "$GRUB_EFI" ]; then
          echo "签名 GRUB EFI: $GRUB_EFI"
          sbctl sign -s "$GRUB_EFI" || true
        fi

        # 只签名最新内核
        LATEST_KERNEL=$(ls -t /boot/kernels/* 2>/dev/null | head -n1)
        if [ -n "$LATEST_KERNEL" ]; then
          echo "签名最新内核: $LATEST_KERNEL"
          sbctl sign -s "$LATEST_KERNEL" || true
        fi

        # 只签名最新 initrd
        LATEST_INITRD=$(ls -t /boot/initrd* 2>/dev/null | head -n1)
        if [ -n "$LATEST_INITRD" ]; then
          echo "签名最新 initrd: $LATEST_INITRD"
          sbctl sign -s "$LATEST_INITRD" || true
        fi

        echo "=== 自动签名完成 ==="
      '';
    };
  };
}
