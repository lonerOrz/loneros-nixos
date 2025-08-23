#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

pkg="./package.nix"

latestTag=$(curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -sL https://api.github.com/repos/mihomo-party-org/mihomo-party/releases/latest | jq -r ".tag_name")
latestVersion="$(expr "$latestTag" : 'v\(.*\)')"

currentVersion=$(grep -E '^\s*version\s*=' "$pkg" | sed -E 's/.*version\s*=\s*"([^"]+)".*/\1/')
echo "latest version: $latestVersion"
echo "current version: $currentVersion"

if [[ $latestVersion == "$currentVersion" ]]; then
  echo "package is up-to-date"
  exit 0
fi

declare -A archMap=(["x86_64-linux"]="amd64" ["aarch64-linux"]="arm64")

for sys in "${!archMap[@]}"; do
  arch=${archMap[$sys]}
  hash="sha256-$(nix hash to-base64 "sha256:$(nix-prefetch-url https://github.com/mihomo-party-org/mihomo-party/releases/download/v$latestVersion/mihomo-party-linux-$latestVersion-$arch.deb)")"

  sed -i -E "/hash = selectSystem \{/,/\};/ s|($sys\s*=\s*\").*(\")|\1$hash\2|" "$pkg"
  echo "Updated $sys hash to $hash"
done

sed -i -E "s/(version\s*=\s*\").*(\")/\1$latestVersion\2/" "$pkg"
