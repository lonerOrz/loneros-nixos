{
  config,
  pkgs,
  lib,
  utils,
  ...
}:

let
  cfg = config.services.btrfs.autoBalance;

  makeServiceAndTimer =
    fs:
    let
      fs' = utils.escapeSystemdPath fs;

      script = pkgs.writeShellScript "btrfs-auto-balance" ''
        #!/usr/bin/env bash
        set -euo pipefail

        FS="${fs}"
        echo "==== Btrfs auto balance check for $FS ===="

        # 防止并发
        if btrfs balance status "$FS" | grep -q "running"; then
          echo "Balance already running, exiting"
          exit 0
        fi

        # 空间保护：剩余 <10GB 不做 balance
        avail=$(df --output=avail -B1 "$FS" | tail -1)
        if [ "$avail" -lt $((10 * 1024 * 1024 * 1024)) ]; then
          echo "Low free space (<10GB), skip balance"
          exit 0
        fi

        df_output=$(btrfs filesystem df "$FS")
        echo "$df_output"

        # Data
        data_line=$(echo "$df_output" | grep "^Data,")
        data_total=$(echo "$data_line" | sed -E 's/.*total=([^,]+).*/\1/')
        data_used=$(echo "$data_line" | sed -E 's/.*used=([^,]+).*/\1/')

        # Metadata
        meta_line=$(echo "$df_output" | grep "^Metadata,")
        meta_total=$(echo "$meta_line" | sed -E 's/.*total=([^,]+).*/\1/')
        meta_used=$(echo "$meta_line" | sed -E 's/.*used=([^,]+).*/\1/')

        # 转换为字节
        data_total_b=$(numfmt --from=iec "$data_total")
        data_used_b=$(numfmt --from=iec "$data_used")

        meta_total_b=$(numfmt --from=iec "$meta_total")
        meta_used_b=$(numfmt --from=iec "$meta_used")

        data_usage=$(awk "BEGIN {print $data_used_b / $data_total_b}")
        meta_usage=$(awk "BEGIN {print $meta_used_b / $meta_total_b}")

        echo "Data usage: $data_usage"
        echo "Metadata usage: $meta_usage"

        SHOULD_BALANCE=0

        # 条件1：data chunk 利用率低
        if awk "BEGIN {exit !($data_usage < ${toString cfg.dataUsageThreshold})}"; then
          echo "Data usage below threshold → trigger balance"
          SHOULD_BALANCE=1
        fi

        # 条件2：metadata 压力高
        if awk "BEGIN {exit !($meta_usage > ${toString cfg.metadataUsageThreshold})}"; then
          echo "Metadata usage high → trigger balance"
          SHOULD_BALANCE=1
        fi

        if [ "$SHOULD_BALANCE" -eq 0 ]; then
          echo "No balance needed"
          exit 0
        fi

        echo "Starting balance (data + metadata)..."

        exec ionice -c3 nice -n 19 \
          btrfs balance start -dusage=${toString cfg.dusage} -musage=${toString cfg.metadataUsage} "$FS"
      '';
    in
    {
      name = "btrfs-auto-balance-${fs'}";
      value = {
        service = {
          description = "Conditional Btrfs balance for ${fs}";

          path = with pkgs; [
            btrfs-progs
            gnugrep
            gawk
            coreutils
            util-linux
          ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = script;
          };
        };

        timer = {
          description = "Btrfs auto balance timer for ${fs}";
          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnCalendar = cfg.interval;
            Persistent = true;
            RandomizedDelaySec = "1h";
          };
        };
      };
    };

  entries = map makeServiceAndTimer cfg.fileSystems;

in
{
  options.services.btrfs.autoBalance = {
    enable = lib.mkEnableOption "conditional btrfs balance";

    fileSystems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/" ];
      description = "Btrfs mount points to balance";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "systemd timer interval";
    };

    dataUsageThreshold = lib.mkOption {
      type = lib.types.float;
      default = 0.75;
      description = "Trigger balance if data usage is below this";
    };

    metadataUsageThreshold = lib.mkOption {
      type = lib.types.float;
      default = 0.80;
      description = "Trigger balance if metadata usage is above this";
    };

    dusage = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "btrfs balance -dusage value for data chunks";
    };

    metadataUsage = lib.mkOption {
      type = lib.types.int;
      default = 80;
      description = "btrfs balance -musage value for metadata chunks";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.listToAttrs (
      map (e: {
        name = e.name;
        value = e.value.service;
      }) entries
    );

    systemd.timers = lib.listToAttrs (
      map (e: {
        name = e.name;
        value = e.value.timer;
      }) entries
    );
  };
}
