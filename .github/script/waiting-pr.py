#!/usr/bin/env python3

import os
import re
import fnmatch
import requests
from pathlib import Path

GITHUB_API = "https://api.github.com"
OWNER = "NixOS"
REPO = "nixpkgs"
BRANCH = "nixpkgs-unstable"

PR_PATTERN = re.compile(
    r"#\s*waiting-pr\s+(https://github\.com/NixOS/nixpkgs/pull/\d+)"
)

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
    r = requests.get(url, headers={"Accept": "application/vnd.github+json"})
    r.raise_for_status()
    return r.json()


def pr_status(pr_url):
    pr_number = pr_url.rsplit("/", 1)[-1]
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

    for path in iter_files():
        try:
            lines = path.read_text(errors="ignore").splitlines()
        except Exception:
            continue

        for idx, line in enumerate(lines, 1):
            m = PR_PATTERN.search(line)
            if not m:
                continue

            pr_url = m.group(1)
            info = pr_status(pr_url)

            results.append({
                "status": info["status"],
                "file": f"{path}:{idx}",
                "pr": pr_url,
                "merged_at": info["merged_at"],
            })

    for item in results:
        print_block(
            item["status"],
            {
                "file": item["file"],
                "pr": item["pr"],
                "merged_at": item["merged_at"],
            }
        )


if __name__ == "__main__":
    main()
