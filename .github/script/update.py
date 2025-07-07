#!/usr/bin/env python3
import os
import subprocess
import re
import argparse
from pathlib import Path


def find_packages(pkgs_dir):
    """扫描 pkgs 目录，查找所有软件包文件路径"""
    packages = []
    pkgs_path = Path(pkgs_dir).resolve()
    print(f"Scanning directory: {pkgs_path}")

    # 查找所有 *.nix 文件
    for item in pkgs_path.rglob("*.nix"):
        # 跳过 packages.nix 和其他非包文件
        if item.name in [
            "packages.nix",
            "default.nix",
            "quickshell.nix",
            "xdman7.nix",
        ]:
            continue

        # 根目录下的 foo.nix，直接把文件路径带回
        if item.parent == pkgs_path and item.name.endswith(".nix"):
            package_name = item.stem
            packages.append((package_name, item))
            print(f"Found package: {package_name} at {item}")

        # 子目录下的 package.nix，同样把文件路径带回
        elif item.name == "package.nix":
            package_name = item.parent.name
            packages.append((package_name, item))
            print(f"Found package: {package_name} at {item}")

    return packages


def check_update_script(package_dir):
    """检查 package.nix 同目录下是否有自定义 update.sh"""
    default_nix = package_dir / "package.nix"
    if not default_nix.exists():
        return None

    try:
        content = default_nix.read_text()
        # 查找 updateScript = ./update.sh
        if re.search(r"updateScript\s*=\s*\./update\.sh", content):
            update_sh = package_dir / "update.sh"
            if update_sh.exists():
                return update_sh
    except Exception as e:
        print(f"Error reading {default_nix}: {e}")

    return None


def update_package(package_name, package_file, extra_args=None):
    """升级单个软件包"""
    extra_args = extra_args or []

    pkg_dir = package_file.parent

    # 优先使用自定义 update.sh
    update_script = check_update_script(pkg_dir)
    if update_script:
        print(f"Updating {package_name} using custom update.sh")
        try:
            subprocess.run(["bash", str(update_script)], check=True, cwd=pkg_dir)
            print(f"Successfully updated {package_name} using update.sh")
        except subprocess.CalledProcessError as e:
            print(f"Failed to update {package_name} using update.sh: {e}")
        return

    # 使用顶层 packages.nix 统一更新
    pkgs_file = "./pkgs/packages.nix"
    cmd = ["nix-update", package_name, "-f", pkgs_file]
    if extra_args:
        cmd.extend(extra_args)

    print(f"Updating {package_name} using nix-update: {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=True, cwd=os.getcwd())
        print(f"Successfully updated {package_name}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to update {package_name}: {e}")


def main():
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
    args = parser.parse_args()

    pkgs_dir = "./pkgs"
    if not os.path.isdir(pkgs_dir):
        print(f"Directory {pkgs_dir} does not exist")
        return

    packages = find_packages(pkgs_dir)
    print(f"找到的packages： {packages}")
    if not packages:
        print("No packages found in pkgs directory")
        return

    # 构建 nix-update 的额外参数列表
    extra_args = []
    if args.commit:
        extra_args.append("--commit")
    if args.test:
        extra_args.append("--test")
    if args.build:
        extra_args.append("--build")
    extra_args.extend(args.extra_args)

    if args.package:
        # 如果指定了 --package，只更新该包
        for pkg_name, pkg_file in packages:
            if pkg_name == args.package:
                update_package(pkg_name, pkg_file, extra_args)
                break
        else:
            print(f"Package {args.package} not found in pkgs directory")
    else:
        # 否则更新所有包
        print(f"Found {len(packages)} packages to update")
        for pkg_name, pkg_file in packages:
            update_package(pkg_name, pkg_file, extra_args)


if __name__ == "__main__":
    main()
