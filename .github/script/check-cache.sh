#!/usr/bin/env bash

set -euo pipefail # Exit on error

CACHES=(
  "https://cache.nixos.org"
  "https://loneros.cachix.org"
  "https://chaotic-nyx.cachix.org"
  "https://hyprland.cachix.org"
)

CACHIX_NAME="loneros"
FLAKE_TARGET=".#nixosConfigurations.loneros.config.system.build.toplevel"
PACKAGE_TARGET=".#nixosConfigurations.loneros.config.environment.systemPackages"

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
  log "DEBUG" "Show packages drv path" >&2

  # 获取所有 drvPath 列表（原始）
  local drv_paths
  drv_paths=$(nix eval --apply 'x: map (pkg: pkg.drvPath) x' \
    --json "$PACKAGE_TARGET" |
    jq -r '.[]' | sort -u)

  if [[ -z $drv_paths ]]; then
    log "ERROR" "No drv paths found for $target" >&2
    return 1
  fi

  # 逐条处理 drvPath，提取对应 out.path
  local paths=()
  local drv out_path
  while IFS= read -r drv; do
    out_path=$(nix derivation show "$drv" 2>/dev/null | jq -r '.[].outputs.out.path')
    if [[ -n $out_path ]]; then
      paths+=("$out_path")
    fi
  done <<<"$drv_paths"

  if [[ ${#paths[@]} -eq 0 ]]; then
    log "ERROR" "No store paths found after derivation inspection for $target" >&2
    return 1
  fi

  # 去重排序
  IFS=$'\n' read -rd '' -a paths < <(printf '%s\n' "${paths[@]}" | sort -u)

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

# 输出所有 systemPackages 的 outPath 和对应的 .drvPath
# 输出格式: "<out_path> <drv_path>"
get_drv_out_mappings() {
  local target="$1"
  log "INFO" "Building drv ↔ outPath mapping for $target"

  local drv_paths
  drv_paths=$(nix eval --apply 'x: map (pkg: pkg.drvPath) x' \
    --json "$PACKAGE_TARGET" | jq -r '.[]' | sort -u)

  if [[ -z $drv_paths ]]; then
    log "ERROR" "No drv paths found from flake target $target"
    return 1
  fi

  local drv out_path
  while IFS= read -r drv; do
    out_path=$(nix derivation show "$drv" 2>/dev/null | jq -r '.[].outputs.out.path')
    if [[ -n $out_path ]]; then
      printf '%s %s\n' "$out_path" "$drv"
    fi
  done <<<"$drv_paths"
}

# Build derivation
build_drv() {
  local drv_path="$1"
  if [[ ! $drv_path =~ ^/nix/store/.*\.drv$ ]]; then
    log "WARN" "Skipping invalid .drv path: '$drv_path'"
    return 1
  fi
  log "INFO" "Building $drv_path"
  # Add ^* suffix as required by newer Nix versions
  local drv_path_fix="${drv_path}^*"
  local cmd=(nix build --no-link "$drv_path_fix" --print-build-logs)
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
  if run nix run nixpkgs#cachix -- push "$CACHIX_NAME" "$path"; then
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

  # 获取 store path 和 out → drv 映射
  declare -A out_to_drv
  while read -r out drv; do
    out_to_drv["$out"]="$drv"
  done < <(get_drv_out_mappings "$FLAKE_TARGET")

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
    drv_path="${out_to_drv["$path"]:-}"
    if [[ -z $drv_path ]]; then
      log "WARN" "No drvPath found for $path"
      exit 1
    fi
    build_drv "$drv_path"
    push_to_cachix "$drv_path"
  done

  log "INFO" "✅ All missing store paths built and pushed successfully."
}

# Trap interrupts and errors
trap 'log "ERROR" "Interrupted."; exit 1' SIGINT
trap 'log "ERROR" "Unexpected error: $?"; exit 1' ERR

main
