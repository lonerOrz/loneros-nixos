#!/usr/bin/env python3
import json
import os
import subprocess
import argparse
import sys

# 1. --suffix
#     * 作用: 指定在备份文件或文件夹时使用的后缀名。
#     * 默认值: backup
#     * 使用示例: 如果你想让备份的文件夹像 nvim-old 这样命名，可以这样运行：
#          ./target/release/tuckr status --json | python3 tuckr_auto_resolve.py --suffix old
#
# 2. --exclude
#     * 作用: 指定一个或多个你不希望脚本处理的配置组。
#     * 默认值: 无（空列表）
#     * 使用示例: 如果你不想让脚本处理 nvim 和 rclone，可以这样运行：
#          ./target/release/tuckr status --json | python3 tuckr_auto_resolve.py --exclude nvim rclone

# ANSI color codes
COLOR_RESET = "\033[0m"
COLOR_BOLD = "\033[1m"
COLOR_RED = "\033[91m"
COLOR_GREEN = "\033[92m"
COLOR_YELLOW = "\033[93m"
COLOR_BLUE = "\033[94m"
COLOR_CYAN = "\033[96m"


def _print_header(text, color=COLOR_CYAN):
    """Prints a formatted header."""
    print(f"\n{color}{COLOR_BOLD}=== {text} ==={COLOR_RESET}")


def _print_success(text):
    """Prints a success message."""
    print(f"{COLOR_GREEN}{text}{COLOR_RESET}")


def _print_error(text):
    """Prints an error message."""
    print(f"{COLOR_RED}{text}{COLOR_RESET}")


def _print_warning(text):
    """Prints a warning message."""
    print(f"{COLOR_YELLOW}{text}{COLOR_RESET}")


def _handle_project_folder_backup(
    original_path, group_name, backup_suffix, exclude_groups, stats
):
    """Handles renaming a project folder for backup and running tuckr add for the group."""
    backup_path = f"{original_path}-{backup_suffix}"
    _print_warning(
        f"  Found project folder '{original_path}'. Attempting to rename it to '{backup_path}' for backup."
    )
    try:
        os.rename(original_path, backup_path)
        _print_success(f"  Successfully renamed '{original_path}' to '{backup_path}'.")
        stats["renamed_folders"] += 1
    except Exception as e:
        _print_error(
            f"  Error renaming '{original_path}': {e}. Skipping tuckr add for this group."
        )
        stats["errors"] += 1
        return False  # Indicate failure

    _print_warning(
        f"  Attempting to resolve conflicts for '{group_name}' by running 'tuckr add {group_name}'."
    )
    cmd = ["tuckr", "add", group_name]
    if exclude_groups:
        cmd.append("--exclude")
        cmd.extend(exclude_groups)

    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        _print_success(f"  Successfully ran 'tuckr add {group_name}'.")
        stats["added_groups"] += 1
    except subprocess.CalledProcessError as e:
        _print_error(f"  Error running 'tuckr add {group_name}': {e.stderr}")
        _print_error(
            f"  Please check the status of '{original_path}' and '{backup_path}' manually."
        )
        stats["errors"] += 1
    return True


def _handle_individual_file_backup(
    conflict_list, group_name, backup_suffix, exclude_groups, stats
):
    """Handles renaming individual conflicting files and running tuckr add for the group."""
    _print_warning(
        f"  No clear project folder found for '{group_name}'. Renaming individual conflict files."
    )
    individual_files_renamed = []
    for conflict_detail in conflict_list:
        target_path = conflict_detail["target_path"]
        reason = conflict_detail["reason"]

        original_file_path = target_path
        backup_file_path = f"{original_file_path}-{backup_suffix}"

        if not os.path.exists(original_file_path):
            _print_warning(
                f"    Warning: '{original_file_path}' not found. Skipping rename."
            )
            stats["warnings"] += 1
            continue

        _print_warning(
            f"    - Conflict file: '{original_file_path}' (Reason: '{reason}'). Attempting to rename to '{backup_file_path}'."
        )
        try:
            os.rename(original_file_path, backup_file_path)
            _print_success(
                f"      Successfully renamed '{original_file_path}' to '{backup_file_path}'."
            )
            individual_files_renamed.append(True)
            stats["renamed_files"] += 1
        except Exception as e:
            _print_error(
                f"      Error renaming '{original_file_path}': {e}. Skipping this file."
            )
            individual_files_renamed.append(False)
            stats["errors"] += 1

    # If at least one file was successfully renamed, try to run tuckr add
    if any(individual_files_renamed):
        _print_warning(
            f"  Attempting to resolve conflicts for '{group_name}' by running 'tuckr add {group_name}'."
        )
        cmd = ["tuckr", "add", group_name]
        if exclude_groups:
            cmd.append("--exclude")
            cmd.extend(exclude_groups)
        try:
            subprocess.run(cmd, check=True, capture_output=True, text=True)
            _print_success(f"  Successfully ran 'tuckr add {group_name}'.")
            stats["added_groups"] += 1
        except subprocess.CalledProcessError as e:
            _print_error(f"  Error running 'tuckr add {group_name}': {e.stderr}")
            _print_error(f"  Please check the status of renamed files manually.")
            stats["errors"] += 1
    else:
        _print_warning(
            f"  No files were successfully renamed for '{group_name}'. Skipping tuckr add."
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
    except json.JSONDecodeError as e:
        _print_error(f"Error decoding JSON input: {e}")
        stats["errors"] += 1
        return stats

    # --- Print Successfully Linked Groups First ---
    symlinked_groups = status_data.get("symlinked", [])
    if symlinked_groups:
        _print_header("Successfully Linked Groups")
        for group in symlinked_groups:
            _print_success(f"  - {group}")
            stats["symlinked_printed"] += 1

    # --- Process Not Yet Linked Groups ---
    not_symlinked_groups = status_data.get("not_symlinked", [])
    if not_symlinked_groups:
        _print_header("Processing Not Yet Linked Groups")
        for group in not_symlinked_groups:
            # Skip excluded groups
            if group in exclude_groups:
                _print_warning(f"  - Skipping excluded group: {group}")
                stats["skipped_excluded"] += 1
                continue
            _print_warning(f"  - Attempting to link: {group}")
            cmd = ["tuckr", "add", group]
            if exclude_groups:
                cmd.append("--exclude")
                cmd.extend(exclude_groups)
            try:
                subprocess.run(cmd, check=True, capture_output=True, text=True)
                _print_success(f"    Successfully linked {group}")
                stats["not_symlinked_processed"] += 1
                stats["added_groups"] += 1
            except subprocess.CalledProcessError as e:
                _print_error(f"    Error linking {group}: {e.stderr}")
                stats["errors"] += 1

    conflicts = status_data.get("conflicts", {})
    if conflicts:
        _print_header("Processing Conflicts")
        target_base_dir = os.path.expanduser(
            "~"
        )  # Get user's home directory, common base for dotfiles

        # Iterate over each group with conflicts
        for group_name, conflict_list in conflicts.items():
            # Skip excluded groups
            if group_name in exclude_groups:
                _print_warning(f"\n--- Skipping excluded group: {group_name} ---")
                stats["skipped_excluded"] += 1
                continue

            _print_warning(f"\n--- Processing conflicts for group: {group_name} ---")
            stats["conflicts_processed"] += 1

            # --- Heuristic to determine if a whole project folder should be backed up ---
            # This tries to find a common root for the group's files in the target system.
            project_folder_to_backup = None
            if conflict_list:
                # Take the target_path of the first conflict to infer the project folder
                first_target_path = conflict_list[0]["target_path"]

                current_check_path = os.path.dirname(
                    first_target_path
                )  # Start checking from the parent of the conflict file

                # Iterate upwards towards the home directory or root
                while (
                    current_check_path
                    and current_check_path != target_base_dir
                    and current_check_path != "/"
                ):
                    basename = os.path.basename(current_check_path)

                    # If a directory matches the group_name, consider it the project folder
                    if basename == group_name:
                        project_folder_to_backup = current_check_path
                        break

                    current_check_path = os.path.dirname(current_check_path)

            # --- Perform backup (rename) and resolution ---
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
        _print_warning("\nNo conflicts found in the provided JSON.")

    # --- Print Unsupported Groups ---
    unsupported_groups = status_data.get("unsupported", [])
    if unsupported_groups:
        _print_header("Unsupported Groups")
        for group in unsupported_groups:
            _print_warning(f"  - {group}")
            stats["unsupported_printed"] += 1

    # --- Print Non-Existent Groups ---
    non_existent_groups = status_data.get("non_existent", [])
    if non_existent_groups:
        _print_header("Non-Existent Groups (Check for typos or missing dotfiles)")
        for group in non_existent_groups:
            _print_warning(f"  - {group}")
            stats["non_existent_printed"] += 1

    # --- Final Summary ---
    _print_header("Processing Summary", color=COLOR_BLUE)
    _print_success(
        f"Total groups processed: {stats['not_symlinked_processed'] + stats['conflicts_processed']}"
    )
    _print_success(f"Groups successfully added/linked: {stats['added_groups']}")
    _print_success(f"Folders renamed for backup: {stats['renamed_folders']}")
    _print_success(f"Files renamed for backup: {stats['renamed_files']}")
    if stats["skipped_excluded"] > 0:
        _print_warning(f"Groups skipped due to exclusion: {stats['skipped_excluded']}")
    if stats["warnings"] > 0:
        _print_warning(f"Total warnings: {stats['warnings']}")
    if stats["errors"] > 0:
        _print_error(f"Total errors: {stats['errors']}")


def main():
    """Main function to parse arguments and initiate conflict processing."""
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
    args = parser.parse_args()

    print("Waiting for JSON input from stdin...")
    json_input = sys.stdin.read()
    process_conflicts(json_input, args.suffix, args.exclude)


if __name__ == "__main__":
    main()
