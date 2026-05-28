#!/usr/bin/env python3
import subprocess
import sys
import json
import re
import math
import os
import threading
import time
from typing import List, Dict, Any
from concurrent.futures import ThreadPoolExecutor, as_completed

CACHES = [
    "https://cache.nixos.org",
    "https://nix-community.cachix.org",
    "https://loneros.cachix.org",
    "https://cache.garnix.io",
    "https://hyprland.cachix.org",
]

HEAVY_BUILD_RULES = {
    "linux_kernel": r"-linux(-\w+)?-\d+\.\d+",
    "electron": r"electron(\b|-|_|$)",
}

PACKAGE_TARGET = ".#nixosConfigurations.loneros.config.environment.systemPackages"
MAX_WORKERS = 6

cache_hits: Dict[str, int] = {cache: 0 for cache in CACHES}
cache_lock = threading.Lock()
log_lock = threading.Lock()
progress_lock = threading.Lock()
progress_counter = 0

def nix_name_version(path: str) -> str:
    if not path.startswith("/nix/store/"):
        return path
    name = path.rsplit("/", 1)[-1]
    if name.endswith(".drv"):
        name = name[:-4]
    parts = name.split("-", 1)
    return parts[1] if len(parts) == 2 else name

def is_heavy_build(drv_path: str) -> bool:
    return any(re.search(pattern, drv_path, re.IGNORECASE) for pattern in HEAVY_BUILD_RULES.values())

def cache_timeout(max_workers: int, num_caches: int) -> float:
    base = 1.5
    alpha = 0.5
    beta = 0.3
    return round(
        base + alpha * math.log2(max_workers) + beta * max(0, num_caches - 1), 2
    )

def log_progress(current: int, total: int, name: str, status: str) -> None:
    with log_lock:
        sys.stderr.write(f"[{current}/{total}] {name} -> {status}\n")
        sys.stderr.flush()

def check_path_in_caches(path: str) -> str | None:
    env = os.environ.copy()
    env["NIXPKGS_ALLOW_INSECURE"] = "1"
    timeout = cache_timeout(MAX_WORKERS, len(CACHES))
    for cache in CACHES:
        try:
            subprocess.run(
                ["nix", "path-info", "--store", cache, path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=timeout,
                check=True,
                env=env,
            )
            with cache_lock:
                cache_hits[cache] += 1
            return urlparse(cache).netloc
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            continue
    return None

def urlparse(url: str):
    from urllib.parse import urlparse as up
    return up(url)

def main() -> None:
    global progress_counter
    print("Evaluating store paths from flake...", file=sys.stderr)

    eval_cmd = [
        "nix", "eval", "--json", "--impure", "--apply",
        "x: map (pkg: if builtins.isAttrs pkg && pkg.drvPath != null && pkg.outPath != null then { name = pkg.name or \"\"; drv = pkg.drvPath; out = pkg.outPath; } else null) x",
        PACKAGE_TARGET
    ]

    env = os.environ.copy()
    env["NIXPKGS_ALLOW_INSECURE"] = "1"

    try:
        raw_output = subprocess.check_output(eval_cmd, env=env).decode("utf-8")
        raw_packages = [p for p in json.loads(raw_output) if p]
    except Exception as e:
        print(f"Error during nix eval: {e}", file=sys.stderr)
        sys.exit(1)

    unique_packages = {}
    for p in raw_packages:
        if "drv" in p:
            unique_packages[p["drv"]] = p

    unique_list = list(unique_packages.values())
    total_paths = len(unique_list)
    print(f"Total unique paths to check: {total_paths}", file=sys.stderr)

    missing_packages = []
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_pkg = {executor.submit(check_path_in_caches, p["out"]): p for p in unique_list}

        for future in as_completed(future_to_pkg):
            pkg = future_to_pkg[future]
            name = pkg["name"] if pkg["name"] else nix_name_version(pkg["drv"])

            with progress_lock:
                progress_counter += 1
                current = progress_counter

            try:
                cache_hit_name = future.result()
                if cache_hit_name:
                    log_progress(current, total_paths, name, f"Cached ({cache_hit_name})")
                else:
                    if is_heavy_build(pkg["drv"]):
                        log_progress(current, total_paths, name, "Missing (Skipped: Heavy Build)")
                    else:
                        log_progress(current, total_paths, name, "Missing (Added to queue)")
                        missing_packages.append({"name": name, "drv": pkg["drv"]})
            except Exception as e:
                log_progress(current, total_paths, name, f"Error: {e}")

    elapsed = time.time() - start_time
    print(f"\nCache check completed in {elapsed:.2f}s", file=sys.stderr)
    print("\nCache hit stats:", file=sys.stderr)
    for cache, hits in cache_hits.items():
        print(f"  {urlparse(cache).netloc}: {hits} hits", file=sys.stderr)

    output_json = json.dumps(missing_packages)
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a") as f:
            f.write(f"missing={output_json}\n")
    else:
        print("\n[Final Output JSON]:")
        print(output_json)

if __name__ == "__main__":
    main()
