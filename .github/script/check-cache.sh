#!/usr/bin/env bash

set -euo pipefail # Exit on error

CACHES=(
  "https://cache.nixos.org"
  "https://loneros.cachix.org"
)

CACHIX_NAME="loneros"
FLAKE_TARGET=".#nixosConfigurations.loneros.config.system.build.toplevel"

# Cache hit statistics
declare -A cache_hits

# Log level (DEBUG for detailed logs, INFO for default)
LOG_LEVEL="DEBUG"

# Log function with timestamp
log() {
  local level="$1"
  local message="$2"
  if [[ $LOG_LEVEL == "DEBUG" || $level != "DEBUG" ]]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$level] $message"
  fi
}

# Run command and capture output
run() {
  local cmd=("$@")
  log "DEBUG" "Running command: ${cmd[*]}"
  local output
  if ! output=$("${cmd[@]}" 2>&1); then
    log "ERROR" "Command failed: ${cmd[*]}"
    log "ERROR" "stderr: $output"
    return 1
  fi
  log "DEBUG" "Command output: $output"
  echo "$output"
}

# Get store paths
get_store_paths() {
  local target="$1"
  log "INFO" "Getting store paths for flake target: $target" >&2
  log "DEBUG" "Running nix path-info --recursive $target" >&2
  local paths
  # paths=$(nix path-info --recursive "$target" | grep -v '\.drv$')
  paths=$(nix derivation show -r "$target" 2>/dev/null |
    jq -r 'keys[] | select(endswith(".drv"))' |
    grep -E '/nix/store/[a-z0-9]{32}-[^/]+-[0-9][^/]*\.drv$' |
    sed 's/\.drv$//' |
    grep -vE '\.(jar|tar\.gz|pom|env|tgz|bz2|zip|xz|gem|patch|pyc|exe|dll|module|cabal|a|o|so|dylib|dev|doc|man|info|html|test|check|example|sample)(\.|$)' |
    grep -E '/nix/store/[a-z0-9]{32}-[^/]+-[^/]+$' |
    sort -u)

  if [[ -z $paths ]]; then
    log "ERROR" "No store paths found for $target" >&2
    exit 1
  fi
  paths=($paths)
  log "INFO" "Found ${#paths[@]} store paths (excluding .drv)" >&2
  printf '%s\n' "${paths[@]}"
}

# Check if path is in cache
is_in_cache() {
  local path="$1"
  log "DEBUG" "Checking path: $path"
  for cache in "${CACHES[@]}"; do
    log "DEBUG" "Checking cache: $cache for $path"
    if timeout 0.5 nix path-info --store "$cache" "$path" >/dev/null 2>&1; then
      log "INFO" "✅ $path is in $cache"
      ((cache_hits["$cache"]++))
      return 0
    else
      log "DEBUG" "Path $path not found in $cache"
    fi
  done
  log "INFO" "🚫 $path not found in any cache"
  return 1
}

# Get derivation path
get_drv_path() {
  local store_path="$1"
  log "INFO" "Getting .drv for $store_path" >&2

  local drv_path
  drv_path=$(timeout 2 nix-store -q --deriver "$store_path" 2>/dev/null || echo "")

  if [[ -z $drv_path ]]; then
    log "WARN" "Skipping $store_path: no derivation found" >&2
    return 1
  fi

  log "INFO" "➡️ $store_path derives from $drv_path" >&2
  echo "$drv_path"
}

# Build derivation
build_drv() {
  local drv_path="$1"
  if [[ ! $drv_path =~ ^/nix/store/.*\.drv$ ]]; then
    log "WARN" "Skipping invalid .drv path: '$drv_path'"
    return 1
  fi
  log "INFO" "Building $drv_path"
  local cmd=(nix build --no-link "$drv_path" --print-build-logs --option substituters "${CACHES[*]}" --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= loneros.cachix.org-1:dVCECfW25sOY3PBHGBUwmQYrhRRK2+p37fVtycnedDU=")
  if run "${cmd[@]}"; then
    log "INFO" "✅ Build succeeded for $drv_path"
  else
    log "ERROR" "Build failed for $drv_path"
    exit 1
  fi
}

# Push to Cachix
push_to_cachix() {
  local path="$1"
  log "INFO" "Pushing $path to Cachix ($CACHIX_NAME)..."
  if run nix run nixpkgs#cachix push "$CACHIX_NAME" "$path"; then
    log "INFO" "✅ Pushed $path"
  else
    log "ERROR" "Push failed for $path"
    exit 1
  fi
}

main() {
  log "INFO" "Starting cache check for $FLAKE_TARGET"
  log "DEBUG" "Calling get_store_paths"

  # 初始化 cache_hits
  for cache in "${CACHES[@]}"; do
    cache_hits["$cache"]=0
  done

  paths_output=$(get_store_paths "$FLAKE_TARGET")
  if [[ -z $paths_output ]]; then
    log "ERROR" "get_store_paths returned empty output."
    exit 1
  fi

  if ! mapfile -t all_paths <<<"$paths_output"; then
    log "ERROR" "Failed to parse store paths into array."
    exit 1
  fi
  missing_paths=()

  log "INFO" "Checking cache presence..."
  for path in "${all_paths[@]}"; do
    if [[ ! $path =~ ^/nix/store/ ]]; then
      log "WARN" "Skipping invalid path: $path"
      continue
    fi
    if ! is_in_cache "$path"; then
      missing_paths+=("$path")
    fi
  done

  log "INFO" "Cache hit statistics:"
  for cache in "${CACHES[@]}"; do
    log "INFO" "$cache: ${cache_hits[$cache]:-0} hits"
  done

  if [[ ${#missing_paths[@]} -eq 0 ]]; then
    log "INFO" "🎉 All paths already in cache. Nothing to build."
    return
  fi

  log "INFO" "Found ${#missing_paths[@]} missing paths. Building individually..."
  for path in "${missing_paths[@]}"; do
    log "DEBUG" "Processing missing path: $path"
    drv_path=$(get_drv_path "$path")
    if [[ $? -ne 0 ]]; then
      continue
    fi
    build_drv "$drv_path"
    push_to_cachix "$path"
  done

  log "INFO" "✅ All missing store paths built and pushed successfully."
}

# Trap interrupts and errors
trap 'log "ERROR" "Interrupted."; exit 1' SIGINT
trap 'log "ERROR" "Unexpected error: $?"; exit 1' ERR

main
