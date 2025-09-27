#!/usr/bin/env python3
import os
import subprocess
import re
import argparse
from pathlib import Path

PKGS_DIR = Path("./pkgs")
PACKAGES_FILE = PKGS_DIR / "packages.nix"
EXCLUDED_FILES = {
    "packages.nix",
    "default.nix",
    "quickshell.nix",
    "xdman7.nix",
    "astronaut-sddm",
    "tuckr",
}
PACKAGE_FILE_NAME = "package.nix"
UPDATE_SH_NAME = "update.sh"


def find_packages(pkgs_dir: Path):
    """扫描 pkgs 目录，查找所有软件包文件路径"""
    packages = []
    pkgs_path = pkgs_dir.resolve()
    print(f"Scanning directory: {pkgs_path}")

    for item in pkgs_path.rglob("*.nix"):
        if item.name in EXCLUDED_FILES:
            continue

        # 顶层 foo.nix
        if item.parent == pkgs_path and item.name.endswith(".nix"):
            package_name = item.stem
            packages.append((package_name, item))
            print(f"Found package: {package_name} at {item}")

        # 子目录 package.nix
        elif item.name == PACKAGE_FILE_NAME:
            package_name = item.parent.name
            packages.append((package_name, item))
            print(f"Found package: {package_name} at {item}")

    return packages


def check_update_script(package_dir: Path):
    """检查 package.nix 同目录下是否有自定义 update.sh"""
    default_nix = package_dir / PACKAGE_FILE_NAME
    if not default_nix.exists():
        return None

    try:
        content = default_nix.read_text()
        if re.search(rf"updateScript\s*=\s*\./{UPDATE_SH_NAME}", content):
            update_sh = package_dir / UPDATE_SH_NAME
            if update_sh.exists():
                return update_sh
    except Exception as e:
        print(f"Error reading {default_nix}: {e}")

    return None


def update_package(package_name: str, package_file: Path, extra_args=None):
    """升级单个软件包"""
    extra_args = extra_args or []
    pkg_dir = package_file.parent

    # 优先使用自定义 update.sh
    update_script = check_update_script(pkg_dir)
    if update_script:
        print(f"Updating {package_name} using custom {UPDATE_SH_NAME}")
        try:
            subprocess.run(["bash", str(update_script)], check=True, cwd=pkg_dir)
            print(f"Successfully updated {package_name} using {UPDATE_SH_NAME}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to update {package_name} using {UPDATE_SH_NAME}: {e}")
        return

    # 使用顶层 packages.nix 统一更新
    cmd = ["nix-update", package_name, "-f", str(PACKAGES_FILE)]
    if extra_args:
        cmd.extend(extra_args)

    print(f"Updating {package_name} using nix-update: {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=True, cwd=os.getcwd())
        print(f"Successfully updated {package_name}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to update {package_name}: {e}")


def parse_args():
    parser = argparse.ArgumentParser(description="Update Nix packages")
    parser.add_argument("--package", help="Specify a single package to update")
    parser.add_argument(
        "--commit", action="store_true", help="Pass --commit to nix-update"
    )
    parser.add_argument("--test", action="store_true", help="Pass --test to nix-update")
    parser.add_argument(
        "--build", action="store_true", help="Pass --build to nix-update"
    )
    parser.add_argument(
        "extra_args", nargs="*", help="Additional arguments for nix-update"
    )
    return parser.parse_args()


def main():
    args = parse_args()

    if not PKGS_DIR.is_dir():
        print(f"Directory {PKGS_DIR} does not exist")
        return

    packages = find_packages(PKGS_DIR)
    if not packages:
        print("No packages found in pkgs directory")
        return

    # 构建额外参数
    extra_args = []
    if args.commit:
        extra_args.append("--commit")
    if args.test:
        extra_args.append("--test")
    if args.build:
        extra_args.append("--build")
    extra_args.extend(args.extra_args)

    if args.package:
        for pkg_name, pkg_file in packages:
            if pkg_name == args.package:
                update_package(pkg_name, pkg_file, extra_args)
                break
        else:
            print(f"Package {args.package} not found in pkgs directory")
    else:
        print(f"Found {len(packages)} packages to update")
        for pkg_name, pkg_file in packages:
            update_package(pkg_name, pkg_file, extra_args)


if __name__ == "__main__":
    main()
