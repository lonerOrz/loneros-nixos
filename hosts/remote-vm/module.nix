{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.tuckr;

  # 每个用户实际执行 tuckr + tuckr.py 的脚本
  userTuckrActivatorScript = pkgs.writeShellScript "user-tuckr-activator" ''
    set -euo pipefail

    tuckr_bin_path="$1"
    dot_path_raw="$2"
    backup_suffix="$3"
    disabled_groups_csv="''${4:-}"   # 空时安全

    if [[ "$dot_path_raw" == "~"* ]]; then
      export TUCKR_HOME="$HOME''${dot_path_raw:1}"
    else
      export TUCKR_HOME="$dot_path_raw"
    fi
    export TUCKR_TARGET="$HOME"
    export TUCKR_BACKUP_SUFFIX="$backup_suffix"
    export TUCKR_DISABLED_GROUPS="$disabled_groups_csv"

    echo "[tuckr] Running for user $USER"
    echo "  TUCKR_HOME=$TUCKR_HOME"
    echo "  TUCKR_BACKUP_SUFFIX=$TUCKR_BACKUP_SUFFIX"
    echo "  TUCKR_DISABLED_GROUPS=$TUCKR_DISABLED_GROUPS"
    echo "  tuckr binary: $tuckr_bin_path"

    tuckr_bin_dir=$(dirname "$tuckr_bin_path")
    export PATH="$tuckr_bin_dir:$PATH"

    PYTHON_ARGS=(--suffix "$backup_suffix")

    if [[ -n "$disabled_groups_csv" ]]; then
      IFS=',' read -ra groups <<< "$disabled_groups_csv"
      for g in "''${groups[@]}"; do
        [[ -n "$g" ]] && PYTHON_ARGS+=(--exclude "$g")
      done
    fi

    if [ -x "$tuckr_bin_path" ]; then
      "$tuckr_bin_path" status --json | "${pkgs.python3}/bin/python3" "${./tuckr.py}" "''${PYTHON_ARGS[@]}"
    else
      echo "[tuckr] ERROR: tuckr binary not found at $tuckr_bin_path"
      exit 1
    fi
  '';

in
{
  options.tuckr = {
    enable = mkEnableOption "Enable multi-user tuckr management";

    package = mkOption {
      type = types.package;
      default = pkgs.tuckr;
      description = "Specify the tuckr package to use";
    };

    users = mkOption {
      type = types.attrsOf (
        types.submodule (_: {
          options = {
            enable = mkEnableOption "Enable tuckr for this user";
            dotPath = mkOption {
              type = types.str;
              description = "TUCKR_HOME path for this user (e.g., ~/.config/tuckr)";
            };
            backupSuffix = mkOption {
              type = types.str;
              default = "bak";
              description = "Backup suffix for tuckr.";
            };
            group = mkOption {
              type = types.attrsOf (
                types.submodule (_: {
                  options = {
                    enable = mkEnableOption "Enable this group for tuckr";
                  };
                })
              );
              default = { };
            };
          };
        })
      );
      default = { };
      description = "Per-user tuckr configuration";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # system-wide service per user
    systemd.services = lib.mapAttrs' (
      username: userCfg:
      let
        enabled_groups_csv = lib.concatStringsSep "," (
          lib.filter (s: s != "") (
            builtins.attrValues (lib.mapAttrs (n: v: if v.enable then n else "") userCfg.group)
          )
        );
        # 禁用的组
        disabled_groups_csv = lib.concatStringsSep "," (
          lib.filter (s: s != "") (
            builtins.attrValues (lib.mapAttrs (n: v: if !v.enable then n else "") userCfg.group)
          )
        );
      in
      {
        name = "tuckr-auto-resolver-${username}";
        value = lib.mkIf userCfg.enable {
          description = "Tuckr auto-resolver for ${username}";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          path = [
            pkgs.coreutils
            pkgs.python3
            cfg.package
          ];
          serviceConfig = {
            Type = "oneshot";
            User = username;
            Environment = "HOME=/home/${username}";
            ExecStart = "${userTuckrActivatorScript} ${cfg.package}/bin/tuckr ${userCfg.dotPath} ${userCfg.backupSuffix} ${disabled_groups_csv}";
          };
        };
      }
    ) cfg.users;

    # rebuild 后统一重启 system-wide 服务
    system.activationScripts.postRebuildTuckr = lib.mkAfter ''
      echo "Activating system-wide tuckr services..."
      ${pkgs.systemd}/bin/systemctl daemon-reload
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          username: userCfg:
          lib.optionalString userCfg.enable ''
            ${pkgs.systemd}/bin/systemctl restart tuckr-auto-resolver-${username}.service || true
          ''
        ) cfg.users
      )}
      echo "Tuckr services activation complete."
    '';
  };
}
