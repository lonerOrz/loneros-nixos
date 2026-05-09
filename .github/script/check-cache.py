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
import os
from urllib.parse import urlparse

# ---------------- Configuration ----------------
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

CACHIX_NAME = "loneros"
FLAKE_TARGET = ".#nixosConfigurations.loneros.config.system.build.toplevel"
PACKAGE_TARGET = ".#nixosConfigurations.loneros.config.environment.systemPackages"

LOG_LEVEL = "DEBUG"
MAX_PUSH_RETRIES = 3
MAX_WORKERS = 10

# Only these levels show timestamps
TIMESTAMP_LEVELS = {"ERROR", "WARN", "STAGE", "SUMMARY"}

# ---------------- Globals ----------------
cache_hits: Dict[str, int] = {}
out_to_drv: Dict[str, str] = {}

cache_lock = threading.Lock()
log_lock = threading.Lock()

USE_COLOR = os.environ.get("NO_COLOR") is None and sys.stdout.isatty()


# ---------------- Color Utilities ----------------
class Color:
    RESET = "\033[0m"
    BOLD = "\033[1m"

    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    CYAN = "\033[36m"
    MAGENTA = "\033[35m"
    GRAY = "\033[90m"


def _c(text: str, color: str, bold: bool = False) -> str:
    if not USE_COLOR:
        return text
    prefix = ""
    if bold:
        prefix += Color.BOLD
    prefix += color
    return f"{prefix}{text}{Color.RESET}"


# ---------------- nix name-version extractor ----------------
def nix_name_version(path: str) -> str:
    if not path.startswith("/nix/store/"):
        return path

    name = path.rsplit("/", 1)[-1]

    if name.endswith(".drv"):
        name = name[:-4]

    parts = name.split("-", 1)
    if len(parts) == 2:
        return parts[1]

    return name


def short_cache_name(url: str) -> str:
    return urlparse(url).netloc


# ---------------- Logging ----------------
def log(level: str, message: str) -> None:
    if LOG_LEVEL != "DEBUG" and level == "DEBUG":
        return

    ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    stream = sys.stderr if level in ("ERROR", "WARN") else sys.stdout

    level_colored = level

    if level == "ERROR":
        level_colored = _c(level, Color.RED, bold=True)
    elif level == "WARN":
        level_colored = _c(level, Color.YELLOW, bold=True)
    elif level == "DEBUG":
        level_colored = _c(level, Color.GRAY)
    elif level == "SUCCESS":
        level_colored = _c(level, Color.GREEN, bold=True)
    elif level == "STAGE":
        level_colored = _c(level, Color.CYAN, bold=True)
    elif level == "SUMMARY":
        level_colored = _c(level, Color.MAGENTA, bold=True)

    with log_lock:
        if level in TIMESTAMP_LEVELS:
            print(f"{ts} [{level_colored}] {message}", file=stream)
        else:
            print(f"[{level_colored}] {message}", file=stream)


# ---------------- Cache Timeout Calculation ----------------
def cache_timeout(max_workers: int, num_caches: int) -> float:
    base = 0.5
    alpha = 0.35
    beta = 0.25
    return round(
        base + alpha * math.log2(max_workers) + beta * max(0, num_caches - 1), 2
    )


# ---------------- Summary Printers ----------------
def print_cache_summary() -> None:
    with log_lock:
        print()

    log("SUMMARY", "Cache hit statistics:")

    for cache in CACHES:
        hits = cache_hits.get(cache, 0)
        hits_str = _c(str(hits), Color.GREEN if hits > 0 else Color.YELLOW, bold=True)
        with log_lock:
            print(f"    {short_cache_name(cache)}: {hits_str} hits")

    with log_lock:
        print()


def print_missing_summary(count: int) -> None:
    if count == 0:
        log("SUCCESS", "All paths already in cache. Nothing to build.")
    else:
        log("SUMMARY", f"Found {count} missing paths. Building individually...")


# ---------------- Command Runner ----------------
def run(
    cmd: List[str],
    timeout: float | None = None,
    stream: bool = False,
) -> str:
    log("DEBUG", f"Running command: {' '.join(cmd)}")

    # 如果需要流式输出（用于 build 等大日志场景）
    if stream:
        result = subprocess.run(
            cmd,
            timeout=timeout,
            stdout=sys.stdout,
            stderr=sys.stderr,
        )
        if result.returncode != 0:
            log("ERROR", f"Command failed: {' '.join(cmd)}")
            raise RuntimeError("command failed")
        return ""

    # 默认：捕获输出（用于 nix eval / cachix 等小输出）
    result = subprocess.run(cmd, capture_output=True, timeout=timeout)

    stdout = result.stdout.decode("utf-8", errors="replace")
    stderr = result.stderr.decode("utf-8", errors="replace")

    if result.returncode != 0:
        log("ERROR", f"Command failed: {' '.join(cmd)}")
        log("ERROR", stderr.strip())
        raise RuntimeError("command failed")

    if LOG_LEVEL == "DEBUG" and stdout.strip():
        if cmd[:2] == ["nix", "eval"] and "--json" in cmd:
            try:
                data = json.loads(stdout)
                if isinstance(data, list):
                    log("DEBUG", f"nix eval returned {len(data)} entries")
                elif isinstance(data, dict):
                    log("DEBUG", f"nix eval returned {len(data)} attributes")
                else:
                    log("DEBUG", "nix eval returned JSON output")
            except Exception:
                log("DEBUG", "nix eval returned non-JSON output")
        else:
            log("DEBUG", stdout.strip())

    return stdout


# ---------------- JSON Runner ----------------
def run_json(cmd: List[str]) -> Any:
    raw = run(cmd)
    if not raw.strip():
        log("WARN", f"nix eval returned empty output for: {' '.join(cmd)}")
        return []
    try:
        return json.loads(raw)
    except json.JSONDecodeError as e:
        log("WARN", f"Failed to parse JSON: {e}")
        return []


# ---------------- Store Path Resolution ----------------
def get_store_paths(target: str) -> List[str]:
    log("STAGE", f"Getting store paths for {target}")

    raw = run_json(
        [
            "nix",
            "eval",
            "--apply",
            "x: map (pkg: if builtins.isAttrs pkg && pkg.drvPath != null then pkg.drvPath else null) x",
            "--json",
            target,
        ]
    )

    seen = set()
    drv_paths: List[str] = []
    for p in raw:
        if p and p not in seen:
            seen.add(p)
            drv_paths.append(str(p))

    if not drv_paths:
        log("ERROR", "No drv paths found")
        raise RuntimeError("no drv paths")

    log("INFO", f"Found {len(drv_paths)} unique .drv paths")
    return drv_paths


# ---------------- drv ↔ outPath Mapping ----------------
def get_drv_out_mappings(target: str) -> None:
    drv_paths = get_store_paths(target)
    for drv in drv_paths:
        out_to_drv[drv] = drv


# ---------------- Cache Lookup ----------------
def is_in_cache(path: str) -> str | None:
    """Return cache name if found, None if missing."""
    for cache in CACHES:
        try:
            subprocess.run(
                ["nix", "path-info", "--store", cache, path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=cache_timeout(MAX_WORKERS, len(CACHES)),
                check=True,
            )
            with cache_lock:
                cache_hits[cache] += 1
            return short_cache_name(cache)
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            continue

    return None


# ---------------- Build + Push ----------------
def is_heavy_build(drv_path: str) -> bool:
    """
    判断是否为耗时构建包
    """
    return any(
        re.search(pattern, drv_path, re.IGNORECASE)
        for pattern in HEAVY_BUILD_RULES.values()
    )


def build_drv(drv_path: str) -> None:
    if not re.match(r"^/nix/store/.*\.drv$", drv_path):
        log("WARN", f"Skipping invalid .drv path: '{drv_path}'")
        return

    if is_heavy_build(drv_path):
        log("INFO", f"Skipping heavy build: {nix_name_version(drv_path)}")
        return

    run(
        [
            "nix",
            "build",
            "--no-link",
            "--keep-going",
            f"{drv_path}^*",
            "--print-build-logs",
        ],
        stream=True,
    )
    log("SUCCESS", f"Build succeeded for {nix_name_version(drv_path)}")


def push_to_cachix(path: str) -> None:
    for attempt in range(1, MAX_PUSH_RETRIES + 1):
        log("INFO", f"Pushing {nix_name_version(path)} (attempt {attempt})...")
        try:
            run(["nix", "run", "nixpkgs#cachix", "--", "push", CACHIX_NAME, path])
            log("SUCCESS", f"Pushed {nix_name_version(path)}")
            return
        except Exception as e:
            log("WARN", f"Push attempt {attempt} failed: {e}")
            time.sleep(3)


# ---------------- Main ----------------
def main() -> None:
    log("STAGE", f"Starting cache check for {PACKAGE_TARGET}")

    for cache in CACHES:
        cache_hits[cache] = 0

    get_drv_out_mappings(PACKAGE_TARGET)
    all_paths = list(out_to_drv.keys())

    missing: List[str] = []

    log("STAGE", "Checking cache presence (parallel)...")

    total = len(all_paths)
    progress = 0
    progress_lock = threading.Lock()
    check_start = time.time()

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {executor.submit(is_in_cache, path): path for path in all_paths}
        for future in as_completed(futures):
            path = futures[future]
            cache_name = future.result()

            with progress_lock:
                progress += 1
                current = progress

            name = nix_name_version(path)
            if cache_name:
                log("SUCCESS", f"[{current}/{total}] {name} → {cache_name}")
            else:
                log("INFO", f"[{current}/{total}] {name} (missing)")
                missing.append(path)

    check_elapsed = time.time() - check_start
    log("SUMMARY", f"Cache check completed in {check_elapsed:.2f}s")

    print_cache_summary()
    print_missing_summary(len(missing))

    if not missing:
        return

    total_build = len(missing)
    build_start = time.time()

    log("STAGE", "Building missing paths...")
    for idx, path in enumerate(missing, 1):
        log("STAGE", f"[{idx}/{total_build}] Building {nix_name_version(path)}")
        build_drv(path)
        push_to_cachix(path)

    build_elapsed = time.time() - build_start
    log("SUCCESS", f"All missing store paths built and pushed in {build_elapsed:.2f}s")


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
