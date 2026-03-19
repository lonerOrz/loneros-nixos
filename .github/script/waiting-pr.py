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

# Configuration
GITHUB_API = "https://api.github.com"
OWNER = "NixOS"
REPO = "nixpkgs"
BRANCH = "nixpkgs-unstable"

# Patterns
PR_PATTERN = re.compile(r"#\s*waiting-pr[:\s]+(\d+)")
PR_FIXES_PATTERN = re.compile(r'^\s*([\w+-]+)\s*=\s*"(\d+)"\s*;')

# ANSI colors
COLORS = {
    "WAITING_MERGE": "\033[33m",
    "MERGED_NOT_IN_UNSTABLE": "\033[35m",
    "READY_IN_UNSTABLE": "\033[32m",
    "CLOSED_NOT_MERGED": "\033[31m",
    "ERROR": "\033[90m",
    "RESET": "\033[0m",
}


class HotfixChecker:
    def __init__(self):
        self.session = requests.Session()
        # Support both GITHUB_TOKEN and GH_TOKEN
        token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
        if token:
            self.session.headers.update({"Authorization": f"Bearer {token}"})
        self.session.headers.update({"Accept": "application/vnd.github+json"})

        self.unstable_sha = None
        self.pr_cache = {}

    def get_unstable_sha(self):
        """Fetch unstable branch latest commit once"""
        if not self.unstable_sha:
            url = f"{GITHUB_API}/repos/{OWNER}/{REPO}/branches/{BRANCH}"
            res = self.session.get(url)
            res.raise_for_status()
            self.unstable_sha = res.json()["commit"]["sha"]
        return self.unstable_sha

    def check_pr_status(self, pr_number):
        """Check PR status with caching"""
        if pr_number in self.pr_cache:
            return self.pr_cache[pr_number]

        try:
            pr_url = f"{GITHUB_API}/repos/{OWNER}/{REPO}/pulls/{pr_number}"
            pr_data = self.session.get(pr_url).json()

            if "state" not in pr_data:
                res = {"status": "ERROR", "at": "PR not found"}
            elif pr_data.get("state") == "closed" and not pr_data.get("merged"):
                res = {"status": "CLOSED_NOT_MERGED", "at": pr_data.get("closed_at")}
            elif not pr_data.get("merged"):
                res = {"status": "WAITING_MERGE", "at": "-"}
            else:
                merge_commit = pr_data["merge_commit_sha"]
                unstable_sha = self.get_unstable_sha()

                comp_url = f"{GITHUB_API}/repos/{OWNER}/{REPO}/compare/{merge_commit}...{unstable_sha}"
                comp_data = self.session.get(comp_url).json()

                if comp_data.get("status") in ("ahead", "identical"):
                    res = {"status": "READY_IN_UNSTABLE", "at": pr_data["merged_at"]}
                else:
                    res = {
                        "status": "MERGED_NOT_IN_UNSTABLE",
                        "at": pr_data["merged_at"],
                    }

            self.pr_cache[pr_number] = res
            return res
        except Exception as e:
            return {"status": "ERROR", "at": str(e)}

    def load_gitignore(self):
        patterns = []
        gitignore = Path(".gitignore")
        if gitignore.exists():
            for line in gitignore.read_text().splitlines():
                line = line.strip()
                if line and not line.startswith("#"):
                    patterns.append(line)
        return patterns

    def ignored(self, path: Path, patterns):
        for pat in patterns:
            if fnmatch.fnmatch(path.as_posix(), pat):
                return True
        return False

    def scan_files(self):
        """Scan all files for # waiting-pr comments and hotfixes.nix"""
        results = []
        ignore_patterns = self.load_gitignore()

        # Scan # waiting-pr comments
        for root, dirs, files in os.walk("."):
            root_path = Path(root)

            # Hard excludes
            dirs[:] = [d for d in dirs if d not in (".git", ".github")]

            for name in files:
                path = root_path / name
                if path.name == ".gitignore":
                    continue
                if self.ignored(path, ignore_patterns):
                    continue

                try:
                    lines = path.read_text(errors="ignore").splitlines()
                    for idx, line in enumerate(lines, 1):
                        m = PR_PATTERN.search(line)
                        if m:
                            pr_number = m.group(1)
                            info = self.check_pr_status(pr_number)
                            results.append(
                                {
                                    "pkg": None,
                                    "pr": pr_number,
                                    "status": info["status"],
                                    "at": info["at"],
                                    "loc": f"{path}:{idx}",
                                }
                            )
                except Exception:
                    continue

        # Scan hotfixes.nix
        hotfixes_path = Path("overlays/hotfixes.nix")
        if hotfixes_path.exists():
            try:
                lines = hotfixes_path.read_text().splitlines()
                for idx, line in enumerate(lines, 1):
                    m = PR_FIXES_PATTERN.match(line)
                    if m:
                        pkg, pr_num = m.groups()
                        info = self.check_pr_status(pr_num)
                        results.append(
                            {
                                "pkg": pkg,
                                "pr": pr_num,
                                "status": info["status"],
                                "at": info["at"],
                                "loc": f"{hotfixes_path}:{idx}",
                            }
                        )
            except Exception:
                pass

        return results

    def display(self, results):
        for item in results:
            c = COLORS.get(item["status"], "")
            reset = COLORS["RESET"]

            if item["pkg"]:
                print(f"{c}[{item['status']}]{reset} {item['pkg']} #{item['pr']}")
            else:
                print(f"{c}[{item['status']}]{reset} PR #{item['pr']}")

            print(f"  Location : {item['loc']}")
            print(f"  Updated  : {item['at']}")

            if item["status"] == "READY_IN_UNSTABLE":
                print(f"  [HINT] You can now safely remove this hotfix!")
            elif item["status"] == "CLOSED_NOT_MERGED":
                print(
                    f"  [WARN] PR is closed but not merged. Check if a new PR exists."
                )
            print()


if __name__ == "__main__":
    checker = HotfixChecker()
    results = checker.scan_files()
    checker.display(results)
