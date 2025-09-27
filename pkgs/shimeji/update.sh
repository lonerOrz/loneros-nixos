#!/usr/bin/env bash
set -euo pipefail

PKG_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_FILE="$PKG_DIR/package.nix"

# Gitea / Codeberg 仓库信息
OWNER="thatonecalculator"
REPO="spamton-linux-shimeji"
DOMAIN="codeberg.org"

# 获取最新提交 hash
LATEST_REV=$(git ls-remote https://$DOMAIN/$OWNER/$REPO.git HEAD | awk '{print $1}')

if [[ -z "$LATEST_REV" ]]; then
    echo "Failed to fetch latest revision."
    exit 1
fi

# 读取当前 package.nix 的 rev
CURRENT_REV=$(grep 'rev\s*=' "$PKG_FILE" | awk -F'"' '{print $2}')

if [[ "$LATEST_REV" == "$CURRENT_REV" ]]; then
    echo "No update needed. Current rev is up-to-date: $CURRENT_REV"
    exit 0
fi

echo "New revision detected: $LATEST_REV (old: $CURRENT_REV)"

# 获取新的 sha256 hash（假装失败一次让 nix-prefetch-git 生成 hash）
RAW_HASH=$(nix-prefetch-git https://$DOMAIN/$OWNER/$REPO.git --rev "$LATEST_REV" | jq -r '.sha256')
NEW_HASH=$(nix hash to-base64 "sha256:$RAW_HASH")
echo "Tarball hash: sha256-$NEW_HASH"

if [[ -z "$NEW_HASH" ]]; then
    echo "Failed to fetch new hash."
    exit 1
fi

# 替换 package.nix 中的 rev 和 hash
sed -i "s|rev = \".*\";|rev = \"$LATEST_REV\";|g" "$PKG_FILE"
sed -i "s|hash = \".*\";|hash = \"sha256-$NEW_HASH\";|g" "$PKG_FILE"

echo "package.nix updated:"
echo "  rev  -> $LATEST_REV"
echo "  hash -> sha256-$NEW_HASH"
