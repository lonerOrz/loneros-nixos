#!/usr/bin/env python3
import subprocess
import sys
import signal
import datetime
import json
import re
from typing import List, Dict, Any
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
import time

# ---------------- Configuration ----------------
CACHES = [
    "https://cache.nixos.org",
    "https://loneros.cachix.org",
    "https://chaotic-nyx.cachix.org",
    "https://hyprland.cachix.org",
]

CACHIX_NAME = "loneros"
FLAKE_TARGET = ".#nixosConfigurations.loneros.config.system.build.toplevel"
PACKAGE_TARGET = ".#nixosConfigurations.loneros.config.environment.systemPackages"

LOG_LEVEL = "DEBUG"
MAX_PUSH_RETRIES = 3

# ---------------- Globals ----------------
cache_hits: Dict[str, int] = {}
out_to_drv: Dict[str, str] = {}

cache_lock = threading.Lock()
log_lock = threading.Lock()

# ---------------- Logging ----------------
def log(level: str, message: str) -> None:
    if LOG_LEVEL == "DEBUG" or level != "DEBUG":
        ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        stream = sys.stderr if level in ("ERROR", "WARN") else sys.stdout
        with log_lock:
            print(f"{ts} [{level}] {message}", file=stream)

# ---------------- Command Runner ----------------
def run(cmd: List[str], timeout: float | None = None) -> str:
    log("DEBUG", f"Running command: {' '.join(cmd)}")
    try:
        p = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired:
        log("ERROR", f"Command timed out: {' '.join(cmd)}")
        raise

    if p.returncode != 0:
        log("ERROR", f"Command failed: {' '.join(cmd)}")
        log("ERROR", p.stdout.strip())
        raise RuntimeError("command failed")

    log("DEBUG", f"Command output: {p.stdout.strip()}")
    return p.stdout

# ---------------- JSON Runner ----------------
def run_json(cmd: List[str]) -> Any:
    raw = run(cmd)
    if not raw.strip():
        log("WARN", f"nix eval returned empty output for: {' '.join(cmd)}")
        return []
    first_brace = raw.find("{")
    first_bracket = raw.find("[")
    if first_brace == -1 and first_bracket == -1:
        log("WARN", f"No JSON found in output for: {' '.join(cmd)}")
        return []
    start = min(x for x in [first_brace, first_bracket] if x != -1)
    clean = raw[start:]
    try:
        return json.loads(clean)
    except json.JSONDecodeError as e:
        log("WARN", f"Failed to parse JSON: {e}")
        return []

# ---------------- Store Path Resolution ----------------
def get_store_paths(target: str) -> List[str]:
    log("INFO", f"Getting store paths for flake target: {target}")
    drv_paths: List[str] = sorted(list({str(p) for p in run_json([
        "nix", "eval",
        "--apply",
        "x: map (pkg: if builtins.isAttrs pkg && pkg.drvPath != null then pkg.drvPath else null) x",
        "--json",
        PACKAGE_TARGET,
    ]) if p}))

    if not drv_paths:
        log("ERROR", f"No drv paths found for {target}")
        raise RuntimeError("no drv paths")

    out_paths: List[str] = []
    for drv in drv_paths:
        try:
            drv_json = run_json(["nix", "derivation", "show", drv])
            for v in drv_json.values():
                out = v.get("outputs", {}).get("out", {}).get("path")
                if out:
                    out_paths.append(f"/nix/store/{out}")
        except Exception:
            continue

    if not out_paths:
        log("ERROR", f"No store paths found after derivation inspection for {target}")
        raise RuntimeError("no store paths")

    out_paths = sorted(set(out_paths))
    log("INFO", f"Found {len(out_paths)} store paths (excluding .drv)")
    return out_paths

# ---------------- Cache Lookup ----------------
def is_in_cache(path: str) -> bool:
    log("DEBUG", f"Checking path: {path}")
    for cache in CACHES:
        log("DEBUG", f"Checking cache: {cache} for {path}")
        try:
            subprocess.run(
                ["nix", "path-info", "--store", cache, path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=0.5,
                check=True,
            )
            log("INFO", f"✅ {path} is in {cache}")
            with cache_lock:
                cache_hits[cache] += 1
            return True
        except Exception:
            log("DEBUG", f"Path {path} not found in {cache}")
    log("INFO", f"🚫 {path} not found in any cache")
    return False

# ---------------- drv ↔ outPath Mapping ----------------
def get_drv_out_mappings(target: str) -> None:
    log("INFO", f"Building drv ↔ outPath mapping for {target}")
    drv_paths: List[str] = sorted(list({str(p) for p in run_json([
        "nix", "eval",
        "--apply",
        "x: map (pkg: pkg.drvPath) x",
        "--json",
        PACKAGE_TARGET,
    ]) if p}))

    if not drv_paths:
        log("WARN", f"No drv paths found from flake target {target}, skipping mapping")
        return

    for drv in drv_paths:
        try:
            drv_json = run_json(["nix", "derivation", "show", drv])
            for v in drv_json.values():
                out = v.get("outputs", {}).get("out", {}).get("path")
                if out:
                    out_to_drv[f"/nix/store/{out}"] = drv
        except Exception:
            continue

# ---------------- Build + Push ----------------
def build_drv(drv_path: str) -> None:
    if not re.match(r"^/nix/store/.*\.drv$", drv_path):
        log("WARN", f"Skipping invalid .drv path: '{drv_path}'")
        return

    log("INFO", f"Building {drv_path}")
    run([
        "nix", "build",
        "--no-link",
        f"{drv_path}^*",
        "--print-build-logs",
    ])
    log("INFO", f"✅ Build succeeded for {drv_path}")

def push_to_cachix(path: str) -> None:
    for attempt in range(1, MAX_PUSH_RETRIES + 1):
        log("INFO", f"Pushing {path} to Cachix ({CACHIX_NAME}), attempt {attempt}...")
        try:
            run([
                "nix", "run", "nixpkgs#cachix",
                "--", "push", CACHIX_NAME, path
            ])
            log("INFO", f"✅ Pushed {path}")
            return
        except Exception as e:
            log("WARN", f"Push attempt {attempt} failed: {e}")
            if attempt == MAX_PUSH_RETRIES:
                log("INFO", "Running nix-collect-garbage and continuing with next path...")
                try:
                    run(["nix-collect-garbage", "-d"])
                except Exception as e_gc:
                    log("WARN", f"GC failed: {e_gc}")
            else:
                time.sleep(5)  # 保留重试间隔

# ---------------- Parallel Cache Check ----------------
def check_one_path(path: str) -> tuple[str, bool]:
    if not path.startswith("/nix/store/"):
        log("WARN", f"Skipping invalid path: {path}")
        return path, True  # 视为已存在
    found = is_in_cache(path)
    return path, found

# ---------------- Main ----------------
def main() -> None:
    log("INFO", f"Starting cache check for {FLAKE_TARGET}")

    for cache in CACHES:
        cache_hits[cache] = 0

    get_drv_out_mappings(FLAKE_TARGET)
    all_paths = get_store_paths(FLAKE_TARGET)

    missing: List[str] = []

    log("INFO", "Checking cache presence...")
    with ThreadPoolExecutor(max_workers=8) as pool:
        futures = {pool.submit(check_one_path, path): path for path in all_paths}
        for future in as_completed(futures):
            path, found = future.result()
            if not found:
                missing.append(path)

    log("INFO", "Cache hit statistics:")
    for cache in CACHES:
        log("INFO", f"{cache}: {cache_hits.get(cache, 0)} hits")

    if not missing:
        log("INFO", "🎉 All paths already in cache. Nothing to build.")
        return

    log("INFO", f"Found {len(missing)} missing paths. Building individually...")
    for path in missing:
        log("DEBUG", f"Processing missing path: {path}")
        drv = out_to_drv.get(path)
        if not drv:
            log("WARN", f"No drvPath found for {path}, skipping.")
            continue
        build_drv(drv)
        push_to_cachix(drv)
        log("INFO", f"Running nix-collect-garbage after {drv}")
        try:
            run(["nix-collect-garbage", "-d"])
        except Exception as e:
            log("WARN", f"GC failed: {e}")

    log("INFO", "✅ All missing store paths built and pushed successfully.")

# ---------------- Signal Handling ----------------
def on_sigint(_signum, _frame):
    log("ERROR", "Interrupted.")
    sys.exit(1)

signal.signal(signal.SIGINT, on_sigint)

# ---------------- Entry Point ----------------
if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        log("ERROR", f"Unexpected error: {e}")
        sys.exit(1)
