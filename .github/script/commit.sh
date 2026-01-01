#!/usr/bin/env bash
set -euo pipefail

# 取消所有暂存改动
git reset HEAD >/dev/null 2>&1 || true

# 获取 pkgs 下有改动的文件
changed_files=$(git diff --name-only HEAD | grep '^pkgs/' || true)

if [ -z "$changed_files" ]; then
  echo "没有检测到 pkgs 下的改动"
  exit 0
fi

for f in $changed_files; do
  pkg=""
  file=""
  add_target=""

  # --- 判断包类型 ---
  if [[ $f == pkgs/*.nix && $f != pkgs/*/* ]]; then
    # 单文件包
    pkg=$(basename "$f" .nix)
    file="$f"
    add_target="$file"
  elif [[ $f == pkgs/*/package.nix || $f == pkgs/*/sources.nix ]]; then
    # 目录包（包含 package.nix 或 sources.nix）
    pkg=$(basename "$(dirname "$f")")
    file="$f"
    add_target="pkgs/$pkg"
  else
    # 其他文件不处理
    continue
  fi

  # --- 1️⃣ 优先检测 version 改动 ---
  if git diff HEAD -- "$file" | grep -qE '^[+-][[:space:]]*version\s*='; then
    old_value=$(git show HEAD:"$file" 2>/dev/null | grep -E '^[[:space:]]*version\s*=' | tail -n1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
    new_value=$(grep -E '^[[:space:]]*version\s*=' "$file" | tail -n1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
    msg="$pkg: ${old_value:-changed} -> ${new_value:-changed}"
    echo "$msg"

    # 只添加包目录或单文件
    git add "$add_target"
    git commit -m "$msg"
    continue
  fi

  # --- 2️⃣ 检测 rev 或 tag 改动 ---
  if git diff HEAD -- "$file" | grep -qE '^[+-][[:space:]]*(rev|tag)\s*='; then
    old_value=$(git show HEAD:"$file" 2>/dev/null | grep -E '^[[:space:]]*(rev|tag)\s*=' | tail -n1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
    new_value=$(grep -E '^[[:space:]]*(rev|tag)\s*=' "$file" | tail -n1 | sed -E 's/.*"([^"]+)".*/\1/' || true)

    # 截取前 7 位显示短 SHA
    old_short=${old_value:0:7}
    new_short=${new_value:0:7}
    msg="$pkg: ${old_short:-changed} -> ${new_short:-changed}"
    echo "$msg"

    # 只添加包目录或单文件
    git add "$add_target"
    git commit -m "$msg"
    continue
  fi

  # --- 3️⃣ 其他改动需手动处理 ---
  echo "⚠️  $pkg 有改动，但不是 version/rev/tag，需手动处理"
done
