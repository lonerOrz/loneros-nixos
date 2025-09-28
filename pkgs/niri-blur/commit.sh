#!/usr/bin/env bash
set -euo pipefail

script_dir=$(dirname "$0")
package_file="$script_dir/package.nix"
pname="niri-blur"

OWNER="lonerOrz"
REPO="niri"
BRANCH="feat/blur"

FAST_MODE=false
if [[ "${1:-}" == "--fast" ]]; then
  FAST_MODE=true
fi

# 1️⃣ 获取远程最新 commit
latest_rev=$(git ls-remote https://github.com/${OWNER}/${REPO}.git ${BRANCH} | cut -f1)
if [ -z "$latest_rev" ]; then
  echo "ERROR: 无法获取 ${OWNER}/${REPO}:${BRANCH} 的最新 commit"
  exit 1
fi
echo "远程最新 commit: $latest_rev"

# 2️⃣ 获取当前 derivation 里的 rev
current_rev=$(grep 'rev = ' "$package_file" | sed -E 's/.*"([^"]+)".*/\1/')
echo "当前 derivation commit: $current_rev"

if [ "$latest_rev" = "$current_rev" ]; then
  echo "✅ 已经是最新 commit，无需更新"
  exit 0
fi

echo "⚡ 检测到新提交，需要更新..."

# 3️⃣ 更新 rev
sed -i "s|rev = \".*\";|rev = \"$latest_rev\";|" "$package_file"

# 4️⃣ 第一次构建：获取 src hash
dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sed -i "s|hash = \".*\";|hash = \"$dummy_src\";|" "$package_file"

echo "Building to get src hash..."
output=$(nix build "$script_dir/../.."#$pname 2>&1 || true)

src_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1)
if [ -z "$src_hash" ]; then
  echo "❌ ERROR: 无法提取 src hash"
  echo "$output" | tail -20
  exit 1
fi
echo "✅ 新源码 hash: $src_hash"
sed -i "s|$dummy_src|$src_hash|" "$package_file"

# 5️⃣ 第二次构建：获取 cargoHash（仅非 fast 模式）
if [ "$FAST_MODE" = false ]; then
  dummy_cargo="sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
  sed -i "s|cargoHash = \".*\";|cargoHash = \"$dummy_cargo\";|" "$package_file"

  echo "Building to get Cargo hash..."
  output=$(NIX_BUILD_CORES=1 nix build "$script_dir/../.."#$pname 2>&1 || true)

  cargo_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1)
  if [ -z "$cargo_hash" ]; then
    echo "❌ ERROR: 无法提取 Cargo hash"
    echo "$output" | tail -20
    exit 1
  fi
  echo "✅ 新 Cargo hash: $cargo_hash"
  sed -i "s|$dummy_cargo|$cargo_hash|" "$package_file"
else
  echo "⚡ fast 模式启用：跳过 cargoHash 更新"
fi

echo "🎉 更新完成！rev=$latest_rev"
