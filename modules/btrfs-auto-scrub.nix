{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
let
  scrubCfg = config.services.btrfs.autoScrub;

  makeServiceAndTimer =
    fs:
    let
      fs' = utils.escapeSystemdPath fs;

      limitArg = lib.optionalString (scrubCfg.limit != null) "--limit ${scrubCfg.limit}";

      script = pkgs.writeShellScript "btrfs-scrub-start-or-resume" ''
        set -e

        echo "checking scrub status for ${fs}..."
        status="$(${pkgs.btrfs-progs}/bin/btrfs scrub status "${fs}")"
        echo "$status"

        # already running → do nothing
        if echo "$status" | grep -q "running"; then
          echo "scrub already running"
          exit 0
        fi

        # interrupted / aborted / cancelled → resume
        if echo "$status" | grep -Eq "(aborted|interrupted|cancelled)"; then
          echo "resuming scrub for ${fs}..."
          exec ${pkgs.util-linux}/bin/ionice -c3 \
               ${pkgs.coreutils}/bin/nice -n 19 \
               ${pkgs.btrfs-progs}/bin/btrfs scrub resume -B ${limitArg} "${fs}"
        fi

        # otherwise → start fresh
        echo "starting scrub for ${fs}..."
        exec ${pkgs.util-linux}/bin/ionice -c3 \
             ${pkgs.coreutils}/bin/nice -n 19 \
             ${pkgs.btrfs-progs}/bin/btrfs scrub start -B ${limitArg} "${fs}"
      '';

      stopScript = pkgs.writeShellScript "btrfs-scrub-maybe-cancel" ''
        if ! ${pkgs.btrfs-progs}/bin/btrfs scrub status "${fs}" | grep -q finished; then
          echo "cancelling unfinished scrub for ${fs}"
          ${pkgs.btrfs-progs}/bin/btrfs scrub cancel "${fs}"
        fi
      '';
    in
    {
      name = "btrfs-auto-scrub-${fs'}";
      value = {
        service = {
          description = "Btrfs auto scrub (start/resume) for ${fs}";
          documentation = [ "man:btrfs-scrub(8)" ];

          conflicts = [
            "shutdown.target"
            "sleep.target"
          ];
          before = [
            "shutdown.target"
            "sleep.target"
          ];

          path = with pkgs; [
            btrfs-progs
            gnugrep
            util-linux
            coreutils
          ];

          serviceConfig = {
            Type = "simple";

            ExecStart = script;
            ExecStop = stopScript;

            Nice = 19;
            IOSchedulingClass = "idle";

            TimeoutSec = "infinity";
          };
        };

        timer = {
          description = "Btrfs auto scrub timer for ${fs}";
          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnCalendar = scrubCfg.interval;

            Persistent = true;
            AccuracySec = "1d";

            RandomizedDelaySec = "1h";
          };
        };
      };
    };

  entries = map makeServiceAndTimer scrubCfg.fileSystems;

in
lib.mkIf scrubCfg.enable {
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
}
