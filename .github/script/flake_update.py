#!/usr/bin/env python3

import subprocess
import json
import sys
from pathlib import Path

# 🛑 要排除更新的 inputs
EXCLUDED_INPUTS = {"lix-module", "nixpkgs"}


def main():
    flake_path = Path("flake.lock")
    if not flake_path.exists():
        print("❌ flake.lock not found. Are you in the correct directory?")
        sys.exit(1)

    with open(flake_path) as f:
        data = json.load(f)

    # 获取 flake 中定义的 inputs（注意：只查 root 的）
    root_node = data.get("nodes", {}).get("root", {})
    all_inputs = root_node.get("inputs", {})

    if not all_inputs:
        print("❌ No inputs found in flake.lock.")
        sys.exit(1)

    # 过滤掉要排除的 inputs
    to_update = [name for name in all_inputs if name not in EXCLUDED_INPUTS]

    if not to_update:
        print("⚠️ No inputs left to update after excluding:", EXCLUDED_INPUTS)
        sys.exit(0)

    print("🔄 Updating inputs (excluding {}):".format(EXCLUDED_INPUTS))
    print("👉 Will update:", to_update)

    # 构造命令：nix flake update input1 input2 ...
    cmd = ["nix", "flake", "update"] + to_update

    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print("❌ Failed to run nix flake update.")
        sys.exit(e.returncode)


if __name__ == "__main__":
    main()
