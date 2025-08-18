#!/usr/bin/env python3
import json
import os
import subprocess
import argparse
import sys
import logging
import shlex

# ANSI color codes
COLOR_RESET = "\033[0m"
COLOR_BOLD = "\033[1m"
COLOR_RED = "\033[91m"
COLOR_GREEN = "\033[92m"
COLOR_YELLOW = "\033[93m"
COLOR_BLUE = "\033[94m"
COLOR_CYAN = "\033[96m"


class ColorFormatter(logging.Formatter):
    COLORS = {
        logging.DEBUG: COLOR_CYAN,
        logging.INFO: COLOR_GREEN,
        logging.WARNING: COLOR_YELLOW,
        logging.ERROR: COLOR_RED,
        logging.CRITICAL: COLOR_BOLD + COLOR_RED,
    }

    def format(self, record):
        color = self.COLORS.get(record.levelno, "")
        message = super().format(record)
        return f"{color}{message}{COLOR_RESET}"


def setup_logging(verbose: bool = False, use_color: bool | None = None) -> None:
    """Configure root logger. If use_color is None, detect by TTY."""
    if use_color is None:
        use_color = sys.stdout.isatty()

    handler = logging.StreamHandler(sys.stdout)
    formatter = (
        ColorFormatter("%(levelname)s: %(message)s")
        if use_color
        else logging.Formatter("%(levelname)s: %(message)s")
    )
    handler.setFormatter(formatter)

    root = logging.getLogger()
    root.handlers.clear()
    root.addHandler(handler)
    root.setLevel(logging.DEBUG if verbose else logging.INFO)


def _run_tuckr_add(group_name, exclude_groups, stats):
    """Run 'tuckr add <group>' with optional --exclude list."""
    cmd = ["tuckr", "add", group_name]
    if exclude_groups:
        cmd.append("--exclude")
        cmd.extend(exclude_groups)

    logging.debug("Running command: %s", " ".join(shlex.quote(c) for c in cmd))
    try:
        completed = subprocess.run(cmd, check=True, capture_output=True, text=True)
        logging.debug("Command stdout:\n%s", completed.stdout.strip())
        logging.info(f"  Successfully ran 'tuckr add {group_name}'.")
        stats["added_groups"] += 1
        return True
    except subprocess.CalledProcessError as e:
        logging.error(
            "  Error running 'tuckr add %s' (code %s): %s",
            group_name,
            e.returncode,
            e.stderr.strip(),
        )
        logging.debug("Command stdout (partial):\n%s", (e.stdout or "").strip())
        stats["errors"] += 1
        return False
    except FileNotFoundError:
        logging.error(
            "  'tuckr' not found in PATH. Ensure the binary is installed and PATH is set."
        )
        stats["errors"] += 1
        return False


def _handle_project_folder_backup(
    original_path, group_name, backup_suffix, exclude_groups, stats
):
    """Handles renaming a project folder for backup and running tuckr add for the group."""
    backup_path = f"{original_path}-{backup_suffix}"
    logging.warning(
        "  Found project folder '%s'. Attempting to rename it to '%s' for backup.",
        original_path,
        backup_path,
    )
    try:
        os.rename(original_path, backup_path)
        logging.info("  Successfully renamed '%s' to '%s'.", original_path, backup_path)
        stats["renamed_folders"] += 1
    except Exception as e:
        logging.error(
            "  Error renaming '%s': %s. Skipping tuckr add for this group.",
            original_path,
            e,
        )
        stats["errors"] += 1
        return False  # Indicate failure

    logging.warning(
        "  Attempting to resolve conflicts for '%s' by running 'tuckr add %s'.",
        group_name,
        group_name,
    )
    return _run_tuckr_add(group_name, exclude_groups, stats)


def _handle_individual_file_backup(
    conflict_list, group_name, backup_suffix, exclude_groups, stats
):
    """Handles renaming individual conflicting files and running tuckr add for the group."""
    logging.warning(
        "  No clear project folder found for '%s'. Renaming individual conflict files.",
        group_name,
    )
    individual_files_renamed = []
    for conflict_detail in conflict_list:
        target_path = conflict_detail["target_path"]
        reason = conflict_detail.get("reason", "unknown")

        original_file_path = target_path
        backup_file_path = f"{original_file_path}-{backup_suffix}"

        if not os.path.exists(original_file_path):
            logging.warning(
                "    Warning: '%s' not found. Skipping rename.", original_file_path
            )
            stats["warnings"] += 1
            continue

        logging.warning(
            "    - Conflict file: '%s' (Reason: '%s'). Attempting to rename to '%s'.",
            original_file_path,
            reason,
            backup_file_path,
        )
        try:
            os.rename(original_file_path, backup_file_path)
            logging.info(
                "      Successfully renamed '%s' to '%s'.",
                original_file_path,
                backup_file_path,
            )
            individual_files_renamed.append(True)
            stats["renamed_files"] += 1
        except Exception as e:
            logging.error(
                "      Error renaming '%s': %s. Skipping this file.",
                original_file_path,
                e,
            )
            individual_files_renamed.append(False)
            stats["errors"] += 1

    # If at least one file was successfully renamed, try to run tuckr add
    if any(individual_files_renamed):
        logging.warning(
            "  Attempting to resolve conflicts for '%s' by running 'tuckr add %s'.",
            group_name,
            group_name,
        )
        _run_tuckr_add(group_name, exclude_groups, stats)
    else:
        logging.warning(
            "  No files were successfully renamed for '%s'. Skipping tuckr add.",
            group_name,
        )
        stats["warnings"] += 1


def process_conflicts(json_input_str, backup_suffix, exclude_groups):
    """Processes the JSON status, performs backups/renames, and attempts to link dotfiles."""
    stats = {
        "symlinked_printed": 0,
        "not_symlinked_processed": 0,
        "conflicts_processed": 0,
        "renamed_folders": 0,
        "renamed_files": 0,
        "added_groups": 0,
        "unsupported_printed": 0,
        "non_existent_printed": 0,
        "skipped_excluded": 0,
        "errors": 0,
        "warnings": 0,
    }

    try:
        status_data = json.loads(json_input_str)
        logging.debug("Parsed JSON keys: %s", list(status_data.keys()))
    except json.JSONDecodeError as e:
        logging.error("Error decoding JSON input: %s", e)
        stats["errors"] += 1
        return stats

    # --- Print Successfully Linked Groups First ---
    symlinked_groups = status_data.get("symlinked", [])
    logging.debug("symlinked count: %d", len(symlinked_groups))
    if symlinked_groups:
        logging.info("=== Successfully Linked Groups ===")
        for group in symlinked_groups:
            logging.debug("Already symlinked group: %s", group)
            logging.info("  - %s", group)
            stats["symlinked_printed"] += 1

    # --- Process Not Yet Linked Groups ---
    not_symlinked_groups = status_data.get("not_symlinked", [])
    logging.debug("not_symlinked count: %d", len(not_symlinked_groups))
    if not_symlinked_groups:
        logging.info("=== Processing Not Yet Linked Groups ===")
        for group in not_symlinked_groups:
            if group in exclude_groups:
                logging.warning("  - Skipping excluded group: %s", group)
                stats["skipped_excluded"] += 1
                continue
            logging.warning("  - Attempting to link: %s", group)
            # Run tuckr add
            if _run_tuckr_add(group, exclude_groups, stats):
                logging.info("    Successfully linked %s", group)
                stats["not_symlinked_processed"] += 1

    # --- Process Conflicts ---
    conflicts = status_data.get("conflicts", {})
    logging.debug("conflicts group count: %d", len(conflicts))
    if conflicts:
        logging.info("=== Processing Conflicts ===")
        # Use environment HOME if available (more robust under systemd)
        target_base_dir = os.environ.get("HOME", os.path.expanduser("~"))
        logging.debug("Base home dir for conflict inference: %s", target_base_dir)

        for group_name, conflict_list in conflicts.items():
            if group_name in exclude_groups:
                logging.warning("--- Skipping excluded group: %s ---", group_name)
                stats["skipped_excluded"] += 1
                continue

            logging.warning("--- Processing conflicts for group: %s ---", group_name)
            logging.debug("Conflict items for %s: %d", group_name, len(conflict_list))
            stats["conflicts_processed"] += 1

            # Try to detect if it's a whole project folder
            project_folder_to_backup = None
            if conflict_list:
                first_target_path = conflict_list[0]["target_path"]
                current_check_path = os.path.dirname(first_target_path)

                while (
                    current_check_path
                    and current_check_path != target_base_dir
                    and current_check_path != "/"
                ):
                    basename = os.path.basename(current_check_path)
                    if basename == group_name:
                        project_folder_to_backup = current_check_path
                        break
                    current_check_path = os.path.dirname(current_check_path)

            logging.debug("Inferred project folder: %s", project_folder_to_backup)

            if project_folder_to_backup and os.path.exists(project_folder_to_backup):
                _handle_project_folder_backup(
                    project_folder_to_backup,
                    group_name,
                    backup_suffix,
                    exclude_groups,
                    stats,
                )
            else:
                _handle_individual_file_backup(
                    conflict_list, group_name, backup_suffix, exclude_groups, stats
                )
    else:
        logging.warning("No conflicts found in the provided JSON.")

    # --- Unsupported Groups ---
    unsupported_groups = status_data.get("unsupported", [])
    logging.debug("unsupported count: %d", len(unsupported_groups))
    if unsupported_groups:
        logging.info("=== Unsupported Groups ===")
        for group in unsupported_groups:
            logging.warning("  - %s", group)
            stats["unsupported_printed"] += 1

    # --- Non-Existent Groups ---
    non_existent_groups = status_data.get("non_existent", [])
    logging.debug("non_existent count: %d", len(non_existent_groups))
    if non_existent_groups:
        logging.info(
            "=== Non-Existent Groups (Check for typos or missing dotfiles) ==="
        )
        for group in non_existent_groups:
            logging.warning("  - %s", group)
            stats["non_existent_printed"] += 1

    # --- Final Summary ---
    logging.info("=== Processing Summary ===")
    logging.info(
        "Total groups processed: %s",
        stats["not_symlinked_processed"] + stats["conflicts_processed"],
    )
    logging.info("Groups successfully added/linked: %s", stats["added_groups"])
    logging.info("Folders renamed for backup: %s", stats["renamed_folders"])
    logging.info("Files renamed for backup: %s", stats["renamed_files"])
    if stats["skipped_excluded"] > 0:
        logging.warning(
            "Groups skipped due to exclusion: %s", stats["skipped_excluded"]
        )
    if stats["warnings"] > 0:
        logging.warning("Total warnings: %s", stats["warnings"])
    if stats["errors"] > 0:
        logging.error("Total errors: %s", stats["errors"])

    return stats


def main():
    parser = argparse.ArgumentParser(
        description="Process tuckr status JSON output to backup and resolve conflicts."
    )
    parser.add_argument(
        "--suffix",
        default="backup",
        help="Suffix to append to renamed backup files/folders. Default is 'backup'.",
    )
    parser.add_argument(
        "--exclude",
        nargs="*",
        default=[],
        help="Groups to exclude when running tuckr add. Accepts multiple values.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable debug logging for more detailed output.",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable ANSI color in log output.",
    )
    args = parser.parse_args()

    setup_logging(verbose=args.verbose, use_color=not args.no_color)

    logging.info("Waiting for JSON input from stdin...")
    json_input = sys.stdin.read()
    process_conflicts(json_input, args.suffix, args.exclude)


if __name__ == "__main__":
    main()
