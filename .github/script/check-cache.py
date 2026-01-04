#!/usr/bin/env python3
import subprocess
import sys
import signal
import datetime
import json
import re
import math
from typing import List, Dict, Any
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
import time

# ---------------- Configuration ----------------
CACHES = [
    "https://cache.nixos.org",
    "https://nix-community.cachix.org",
    "https://loneros.cachix.org",
    "https://cache.garnix.io",
    "https://hyprland.cachix.org",
]

CACHIX_NAME = "loneros"
FLAKE_TARGET = ".#nixosConfigurations.loneros.config.system.build.toplevel"
PACKAGE_TARGET = ".#nixosConfigurations.loneros.config.environment.systemPackages"

LOG_LEVEL = "DEBUG"
MAX_PUSH_RETRIES = 3
MAX_WORKERS = 10

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
    p = None
    try:
        with subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True,
        ) as p:
            output_lines = []
            if p.stdout:
                for line in p.stdout:
                    output_lines.append(line)
                    print(str(line.rstrip()))
            p.wait(timeout=timeout)
            if p.returncode != 0:
                log("ERROR", str(f"Command failed: {' '.join(cmd)}"))
                log("ERROR", str("".join(output_lines).strip()))
                raise RuntimeError("command failed")
            log("DEBUG", str(f"Command output: {''.join(output_lines).strip()}"))
            return str("".join(output_lines))
    except subprocess.TimeoutExpired:
        log("ERROR", f"Command timed out: {' '.join(cmd)}")
        if p:
            p.kill()
        raise

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

    log("INFO", f"Found {len(drv_paths)} .drv paths")
    return drv_paths  # 直接返回 .drv 路径

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
        out_to_drv[drv] = drv  # drv -> drv 映射

# ---------------- Cache Timeout Calculation ----------------
def cache_timeout(max_workers: int, num_caches: int) -> float:
    base = 0.5  # TLS + DNS 基础成本
    α = 0.25  # 并行放大因子
    β = 0.15  # cache 串行累积

    return round(
        base
        + α * math.log2(max_workers)
        + β * max(0, num_caches - 1),
        2
    )

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
                timeout=cache_timeout(MAX_WORKERS, len(CACHES)),
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
                time.sleep(5)  # 重试间隔

# ---------------- Parallel Cache Check ----------------
def check_one_path(path: str) -> tuple[str, bool]:
    if not path.startswith("/nix/store/"):
        log("WARN", f"Skipping invalid path: {path}")
        return path, True  # 视为已存在
    found = is_in_cache(path)
    return path, found

# ---------------- Main (with parallel cache check) ----------------
def main() -> None:
    log("INFO", str(f"Starting cache check for {FLAKE_TARGET}"))

    for cache in CACHES:
        cache_hits[cache] = 0

    get_drv_out_mappings(FLAKE_TARGET)
    all_paths = get_store_paths(FLAKE_TARGET)

    missing: List[str] = []

    log("INFO", str("Checking cache presence (parallel)..."))
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:  # 可调整线程数
        futures = {executor.submit(check_one_path, path): path for path in all_paths}
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

    log("INFO", str(f"Found {len(missing)} missing paths. Building individually..."))
    with ThreadPoolExecutor(max_workers=1) as executor:  # 构建线程数为1
        futures = {executor.submit(build_and_push, path): path for path in missing}
        for future in as_completed(futures):
            future.result()

    log("INFO", "✅ All missing store paths built and pushed successfully.")

# ---------------- Build and Push ----------------
def build_and_push(path: str) -> None:
    log("DEBUG", f"Processing missing path: {path}")
    drv = out_to_drv.get(path)
    if not drv:
        log("WARN", f"No drvPath found for {path}, skipping.")
        return
    build_drv(drv)
    push_to_cachix(drv)
    # try:
    #     run(["nix-collect-garbage", "-d"])
    # except Exception as e:
    #     log("WARN", f"GC failed: {e}")

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
