#!/usr/bin/env python3
"""
Scan both # waiting-pr comments and hotfixes.nix to show PR merge status.

Usage:
  - Stage 2: Add `# waiting-pr 123456` comment in overlay files
  - Stage 3: Add `package-name = "123456";` in overlays/hotfixes.nix
"""

import os
import re
import fnmatch
import requests
from pathlib import Path

GITHUB_API = "https://api.github.com"
OWNER = "NixOS"
REPO = "nixpkgs"
BRANCH = "nixpkgs-unstable"

# 匹配模式：# waiting-pr 123456 或 # waiting-pr: 123456
PR_PATTERN = re.compile(r"#\s*waiting-pr[:\s]+(\d+)")

# 匹配 pr-fixes.nix: package-name = "123456";
PR_FIXES_PATTERN = re.compile(r'^\s*([\w+-]+)\s*=\s*"(\d+)"\s*;\s*(?:#.*)?$')

# ANSI colors
RESET = "\033[0m"
COLORS = {
    "WAITING_MERGE": "\033[33m",            # yellow
    "MERGED_NOT_IN_UNSTABLE": "\033[35m",   # magenta
    "READY_IN_UNSTABLE": "\033[32m",        # green
}


def load_gitignore():
    patterns = []
    if Path(".gitignore").exists():
        for line in Path(".gitignore").read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                patterns.append(line)
    return patterns


def ignored(path: Path, patterns):
    for pat in patterns:
        if fnmatch.fnmatch(path.as_posix(), pat):
            return True
    return False


def iter_files():
    ignore_patterns = load_gitignore()
    for root, dirs, files in os.walk("."):
        root_path = Path(root)

        # hard excludes
        dirs[:] = [
            d for d in dirs
            if d not in (".git", ".github")
        ]

        for name in files:
            path = root_path / name
            if path.name == ".gitignore":
                continue
            if ignored(path, ignore_patterns):
                continue
            yield path


def github_get(url):
    headers = {"Accept": "application/vnd.github+json"}
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    r = requests.get(url, headers=headers)
    r.raise_for_status()
    return r.json()


def pr_status(pr_number):
    pr = github_get(f"{GITHUB_API}/repos/{OWNER}/{REPO}/pulls/{pr_number}")

    if not pr["merged"]:
        return {
            "status": "WAITING_MERGE",
            "merged_at": "-"
        }

    merge_commit = pr["merge_commit_sha"]
    merged_at = pr["merged_at"]

    branch = github_get(
        f"{GITHUB_API}/repos/{OWNER}/{REPO}/branches/{BRANCH}"
    )
    unstable_head = branch["commit"]["sha"]

    compare = github_get(
        f"{GITHUB_API}/repos/{OWNER}/{REPO}/compare/{merge_commit}...{unstable_head}"
    )

    if compare["status"] in ("ahead", "identical"):
        status = "READY_IN_UNSTABLE"
    else:
        status = "MERGED_NOT_IN_UNSTABLE"

    return {
        "status": status,
        "merged_at": merged_at
    }


def print_block(status, fields):
    color = COLORS.get(status, "")
    print(f"{color}[{status}]{RESET}")
    for key, value in fields.items():
        print(f"  {key:<10} : {value}")
    print()


def main():
    results = []

    # Scan # waiting-pr comments in all files
    for path in iter_files():
        try:
            lines = path.read_text(errors="ignore").splitlines()
        except Exception:
            continue

        for idx, line in enumerate(lines, 1):
            m = PR_PATTERN.search(line)
            if not m:
                continue

            pr_number = m.group(1)
            info = pr_status(pr_number)
            pr_url = f"https://github.com/{OWNER}/{REPO}/pull/{pr_number}"

            results.append({
                "status": info["status"],
                "file": f"{path}:{idx}",
                "pr": pr_url,
                "merged_at": info["merged_at"],
            })

    # Scan hotfixes.nix
    hotfixes_path = Path("overlays/hotfixes.nix")
    if hotfixes_path.exists():
        try:
            lines = hotfixes_path.read_text().splitlines()
            for idx, line in enumerate(lines, 1):
                m = PR_FIXES_PATTERN.match(line)
                if not m:
                    continue

                pkg_name = m.group(1)
                pr_number = m.group(2)
                info = pr_status(pr_number)
                pr_url = f"https://github.com/{OWNER}/{REPO}/pull/{pr_number}"

                results.append({
                    "status": info["status"],
                    "file": f"{hotfixes_path}:{idx}",
                    "pr": pr_url,
                    "merged_at": info["merged_at"],
                    "package": pkg_name,
                })
        except Exception:
            pass

    for item in results:
        fields = {
            "file": item["file"],
            "pr": item["pr"],
            "merged_at": item["merged_at"],
        }
        if "package" in item:
            fields["package"] = item["package"]
        print_block(item["status"], fields)


if __name__ == "__main__":
    main()
