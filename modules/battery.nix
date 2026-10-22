{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.battery-manager;
  # 静态引用包装器目录，避免读取 config.security.wrapperDir 造成模块自引用死循环。
  wrapperDir = "/run/wrappers/bin";

  # 通用后端：编译为 ELF 二进制，满足 NixOS 26.11 的 wrapper 完整性要求
  batteryManagerBackend = pkgs.stdenv.mkDerivation {
    name = "battery-manager-backend";

    src = pkgs.writeText "battery-manager-backend.c" ''
      #include <stdio.h>
      #include <stdlib.h>
      #include <syslog.h>

      static const char *const battery_paths[] = {
        ${lib.concatMapStringsSep "\n        " (p: "${builtins.toJSON p},") cfg.battery-paths}
        NULL,
      };

      int main(int argc, char **argv) {
        openlog("battery-manager", LOG_PID, LOG_DAEMON);

        if (argc != 2) {
          fprintf(stderr, "Usage: battery-manager-backend <0-100>\n");
          syslog(LOG_ERR, "Invalid argument count");
          closelog();
          return 1;
        }

        int invalid = argv[1][0] == '\0';

        for (const char *p = argv[1]; *p != '\0'; p++) {
          if (*p < '0' || *p > '9') {
            invalid = 1;
            break;
          }
        }

        char *end = NULL;
        long level = strtol(argv[1], &end, 10);

        if (invalid || end == argv[1] || *end != '\0' ||
            level < 0 || level > 100) {
          fprintf(stderr, "Battery level must be 0-100\n");
          syslog(LOG_ERR, "Invalid battery level: %s", argv[1]);
          closelog();
          return 1;
        }

        for (const char *const *p = battery_paths; *p != NULL; p++) {
          FILE *f = fopen(*p, "w");

          if (f == NULL)
            continue;

          int failed = fprintf(f, "%ld\n", level) < 0;

          if (fclose(f) != 0)
            failed = 1;

          if (failed) {
            syslog(LOG_ERR, "Failed to write threshold to %s", *p);
            continue;
          }

          syslog(LOG_INFO, "Set battery threshold to %ld%% on %s",
                 level, *p);
          closelog();
          return 0;
        }

        fprintf(stderr, "No writable battery threshold path found.\n");
        syslog(LOG_ERR, "No writable battery threshold path found");
        closelog();
        return 3;
      }
    '';

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      $CC -O2 -Wall -Wextra -o battery-manager-backend "$src"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 battery-manager-backend \
        "$out/bin/battery-manager-backend"
      runHook postInstall
    '';
  };

  # 联想后端：目标文件在构建时固定，只接受 0 或 1
  batteryConservationBackend = pkgs.stdenv.mkDerivation {
    name = "battery-conservation-backend";

    src = pkgs.writeText "battery-conservation-backend.c" ''
      #include <stdio.h>
      #include <string.h>
      #include <syslog.h>

      static const char *const mode_file =
        ${builtins.toJSON cfg.conservation.mode-file};

      int main(int argc, char **argv) {
        openlog("battery-conservation", LOG_PID, LOG_DAEMON);

        if (argc != 2 ||
            (strcmp(argv[1], "0") != 0 &&
             strcmp(argv[1], "1") != 0)) {
          fprintf(stderr,
                  "Usage: battery-conservation-backend <0|1>\n");
          syslog(LOG_ERR, "Invalid conservation mode argument");
          closelog();
          return 1;
        }

        FILE *f = fopen(mode_file, "w");

        if (f == NULL) {
          perror("Failed to open conservation mode file");
          syslog(LOG_ERR, "Failed to open %s", mode_file);
          closelog();
          return 2;
        }

        int failed = fprintf(f, "%s\n", argv[1]) < 0;

        if (fclose(f) != 0)
          failed = 1;

        if (failed) {
          perror("Failed to write conservation mode");
          syslog(LOG_ERR, "Failed to write %s", mode_file);
          closelog();
          return 3;
        }

        syslog(LOG_INFO, "Set conservation mode to %s", argv[1]);
        closelog();
        return 0;
      }
    '';

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      $CC -O2 -Wall -Wextra -o battery-conservation-backend "$src"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 battery-conservation-backend \
        "$out/bin/battery-conservation-backend"
      runHook postInstall
    '';
  };

  batteryConservationBackendPath = "${batteryConservationBackend}/bin/battery-conservation-backend";

  # 统一前端名称；具体命令由设备类型决定
  batteryManagerFrontend =
    if cfg.is-lenovo then
      pkgs.writeShellApplication {
        name = "battery-manager";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.libnotify
        ];

        text = ''
          MODE_FILE=${lib.escapeShellArg cfg.conservation.mode-file}
          BACKEND=${lib.escapeShellArg batteryConservationBackendPath}
          SUDO=${lib.escapeShellArg "${wrapperDir}/sudo"}
          QUIET=false

          usage() {
            printf '%s\n' \
              "Usage: battery-manager [--quiet] <command>" \
              "" \
              "Commands:" \
              "  on       Enable conservation mode" \
              "  off      Disable conservation mode" \
              "  status   Show current mode" \
              "  toggle   Toggle current mode" \
              "  help     Show this help" \
              "" \
              "Options:" \
              "  -q, --quiet  Suppress desktop notifications"
          }

          print_error() {
            printf '%s\n' "$1" >&2
          }

          notify() {
            if [ "$QUIET" = false ]; then
              notify-send "$@" || true
            fi
          }

          # 允许在命令前后使用 --quiet
          ARGS=()

          for arg in "$@"; do
            case "$arg" in
              -q|--quiet)
                QUIET=true
                ;;
              *)
                ARGS+=("$arg")
                ;;
            esac
          done

          set -- "''${ARGS[@]}"

          case "''${1:-}" in
            ""|help|-h|--help)
              if [ "$#" -gt 1 ]; then
                print_error "Unexpected arguments"
                exit 2
              fi
              usage
              exit 0
              ;;
            set)
              print_error \
                "'set' is unavailable in Lenovo conservation mode"
              exit 2
              ;;
            on|off|status|toggle)
              if [ "$#" -ne 1 ]; then
                print_error "Unexpected arguments"
                usage >&2
                exit 2
              fi
              ;;
            *)
              print_error "Unknown command: $1"
              usage >&2
              exit 2
              ;;
          esac

          if [ ! -e "$MODE_FILE" ]; then
            print_error \
              "$MODE_FILE not found; check device compatibility"
            exit 1
          fi

          read_mode() {
            local mode

            if ! mode="$(cat -- "$MODE_FILE")"; then
              print_error "Failed to read conservation mode"
              return 1
            fi

            case "$mode" in
              0|1)
                printf '%s\n' "$mode"
                ;;
              *)
                print_error "Invalid conservation mode value: $mode"
                return 1
                ;;
            esac
          }

          set_mode() {
            case "$1" in
              0|1) ;;
              *)
                print_error "Invalid conservation mode: $1"
                return 2
                ;;
            esac

            if ! "$SUDO" -n "$BACKEND" "$1"; then
              print_error "Failed to update conservation mode"
              return 1
            fi
          }

          enable_mode() {
            if ! set_mode 1; then
              notify -u critical \
                "Conservation Mode Failed" \
                "Failed to enable conservation mode."
              return 1
            fi

            printf '%s\n' \
              "Conservation mode ENABLED (charging capped at approximately 60%)."

            notify -u normal -i battery-good \
              "Conservation Mode Enabled" \
              "Charging capped at approximately 60%."
          }

          disable_mode() {
            if ! set_mode 0; then
              notify -u critical \
                "Conservation Mode Failed" \
                "Failed to disable conservation mode."
              return 1
            fi

            printf '%s\n' \
              "Conservation mode DISABLED (charging allowed up to 100%)."

            notify -u normal -i battery-full \
              "Conservation Mode Disabled" \
              "Charging allowed up to 100%."
          }

          show_status() {
            local mode

            mode="$(read_mode)" || return 1

            if [ "$mode" = 1 ]; then
              printf '%s\n' \
                "Conservation mode is ENABLED (charging capped at approximately 60%)."

              notify -u normal -i battery-good \
                "Conservation Mode Status" \
                "Enabled; charging capped at approximately 60%."
            else
              printf '%s\n' \
                "Conservation mode is DISABLED (charging allowed up to 100%)."

              notify -u normal -i battery-full \
                "Conservation Mode Status" \
                "Disabled; charging allowed up to 100%."
            fi
          }

          case "$1" in
            on)
              enable_mode
              ;;
            off)
              disable_mode
              ;;
            status)
              show_status
              ;;
            toggle)
              CURRENT_MODE="$(read_mode)" || exit 1

              if [ "$CURRENT_MODE" = 0 ]; then
                enable_mode
              else
                disable_mode
              fi
              ;;
          esac
        '';
      }
    else
      pkgs.writeShellApplication {
        name = "battery-manager";
        runtimeInputs = [ pkgs.libnotify ];

        text = ''
          BACKEND=${lib.escapeShellArg "${wrapperDir}/battery-manager-backend"}
          PKEXEC=${lib.escapeShellArg "${wrapperDir}/pkexec"}
          QUIET=false

          usage() {
            printf '%s\n' \
              "Usage: battery-manager [--quiet] set <0-100>" \
              "" \
              "Commands:" \
              "  set <0-100>  Set battery charging threshold" \
              "  help         Show this help" \
              "" \
              "Options:" \
              "  -q, --quiet  Suppress desktop notifications"
          }

          print_error() {
            printf '%s\n' "$1" >&2
          }

          notify() {
            if [ "$QUIET" = false ]; then
              notify-send "$@" || true
            fi
          }

          # 允许在命令前后使用 --quiet
          ARGS=()

          for arg in "$@"; do
            case "$arg" in
              -q|--quiet)
                QUIET=true
                ;;
              *)
                ARGS+=("$arg")
                ;;
            esac
          done

          set -- "''${ARGS[@]}"

          case "''${1:-}" in
            ""|help|-h|--help)
              if [ "$#" -gt 1 ]; then
                print_error "Unexpected arguments"
                exit 2
              fi
              usage
              exit 0
              ;;
            set)
              ;;
            on|off|status|toggle)
              print_error \
                "'$1' is unavailable outside Lenovo conservation mode"
              exit 2
              ;;
            *)
              print_error "Unknown command: $1"
              usage >&2
              exit 2
              ;;
          esac

          if [ "$#" -ne 2 ]; then
            print_error "Expected one battery threshold"
            usage >&2
            exit 2
          fi

          BATTERY_LEVEL="$2"

          if ! [[ "$BATTERY_LEVEL" =~ ^(0|[1-9][0-9]?|100)$ ]]; then
            print_error "Battery level must be an integer from 0 to 100"
            exit 2
          fi

          printf 'Setting battery threshold to %s%%...\n' "$BATTERY_LEVEL"

          if "$PKEXEC" "$BACKEND" "$BATTERY_LEVEL"; then
            printf 'Successfully set battery threshold to %s%%.\n' \
              "$BATTERY_LEVEL"

            notify -u normal \
              "Battery Threshold Updated" \
              "Threshold set to $BATTERY_LEVEL%"
          else
            backend_status=$?

            print_error "Failed to set battery charging threshold."

            notify -u critical \
              "Battery Threshold Failed" \
              "Failed to set battery threshold to $BATTERY_LEVEL%"

            exit "$backend_status"
          fi
        '';
      };
in
{
  options.services.battery-manager = {
    enable = lib.mkEnableOption "启用电池管理器";

    # 两种后端互斥，由设备类型决定
    is-lenovo = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        是否为联想设备。true 使用 conservation_mode；
        false 使用自定义充电阈值。
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "wheel";
      description = "可免认证调用电池管理后端的用户组。";
    };

    battery-paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/sys/class/power_supply/BAT0/charge_control_end_threshold"
        "/sys/class/power_supply/BAT1/charge_control_end_threshold"
        "/sys/class/power_supply/BAT0/charge_stop_threshold"
        "/sys/class/power_supply/BAT1/charge_stop_threshold"
      ];
      description = ''
        自定义充电阈值后端尝试写入的 sysfs 路径列表。
        仅在 is-lenovo = false 时使用。
      '';
    };

    conservation.mode-file = lib.mkOption {
      type = lib.types.str;
      default = "/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";
      description = ''
        联想 ideapad conservation_mode 的 sysfs 路径。
        1 表示启用节能模式，0 表示关闭节能模式。
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 联想：保养模式（sudo NOPASSWD 调用 conservation 后端）
      (lib.mkIf cfg.is-lenovo {
        environment.systemPackages = [
          batteryManagerFrontend
        ];

        security.sudo.enable = true;

        security.sudo.extraRules = [
          {
            groups = [ cfg.group ];
            runAs = "root";
            commands =
              map
                (mode: {
                  command = "${batteryConservationBackendPath} ${mode}";
                  options = [ "NOPASSWD" ];
                })
                [
                  "0"
                  "1"
                ];
          }
        ];
      })

      # 其他设备：自定义阈值后端（polkit + setuid wrapper）
      (lib.mkIf (!cfg.is-lenovo) {
        environment.systemPackages = [
          batteryManagerFrontend
        ];

        security.polkit.enable = true;
        security.polkit.enablePkexecWrapper = true;

        # wrapper 的 source 必须是 ELF 二进制
        security.wrappers."battery-manager-backend" = {
          owner = "root";
          group = "root";
          setuid = false;
          source = "${batteryManagerBackend}/bin/battery-manager-backend";
        };

        # 组内用户可以免认证调用指定后端
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.policykit.exec" &&
                action.lookup("program") ==
                  ${builtins.toJSON "${wrapperDir}/battery-manager-backend"} &&
                subject.isInGroup(${builtins.toJSON cfg.group})) {
              return polkit.Result.YES;
            }
          });
        '';
      })
    ]
  );
}
