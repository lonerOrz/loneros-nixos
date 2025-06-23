import os
import subprocess
import re
import argparse
from pathlib import Path


def find_packages(pkgs_dir):
    """扫描pkgs目录，查找所有软件包"""
    packages = []
    pkgs_path = Path(pkgs_dir).resolve()
    print(f"Scanning directory: {pkgs_path}")

    # 查找所有 *.nix 文件
    for item in pkgs_path.rglob("*.nix"):
        # 跳过 packages.nix 和其他非包文件
        if item.name in ["packages.nix", "default.nix.bak", "quickshell.nix"]:
            continue
        # 如果是 pkgs 根目录下的 xxx.nix 文件
        if item.parent == pkgs_path and item.name.endswith(".nix"):
            package_name = item.stem
            packages.append((package_name, item.parent))
            print(f"Found package: {package_name} at {item}")
        # 如果是子目录下的 default.nix
        elif item.name == "default.nix":
            package_name = item.parent.name
            packages.append((package_name, item.parent))
            print(f"Found package: {package_name} at {item.parent}")

    return packages


def check_update_script(package_dir):
    """检查default.nix中是否有updateScript标志"""
    default_nix = package_dir / "default.nix"
    if not default_nix.exists():
        return None

    try:
        with open(default_nix, "r") as f:
            content = f.read()
            # 查找 updateScript = ./update.sh
            match = re.search(r"updateScript\s*=\s*\./update\.sh", content)
            if match:
                update_sh = package_dir / "update.sh"
                if update_sh.exists():
                    return update_sh
    except Exception as e:
        print(f"Error reading {default_nix}: {e}")

    return None


def update_package(package_name, package_dir, extra_args=None):
    """升级单个软件包"""
    extra_args = extra_args or []

    # 检查是否有自定义update.sh
    update_script = check_update_script(package_dir)
    if update_script:
        print(f"Updating {package_name} using custom update.sh")
        try:
            subprocess.run(["bash", str(update_script)], check=True, cwd=package_dir)
            print(f"Successfully updated {package_name} using update.sh")
        except subprocess.CalledProcessError as e:
            print(f"Failed to update {package_name} using update.sh: {e}")
        return

    # 使用nix-update进行升级
    cmd = ["nix-update", package_name, "-f", "./pkgs/packages.nix"]
    if extra_args:
        cmd.extend(extra_args)

    print(f"Updating {package_name} using nix-update: {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=True, cwd=os.getcwd())
        print(f"Successfully updated {package_name}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to update {package_name}: {e}")


def main():
    # 解析命令行参数
    parser = argparse.ArgumentParser(description="Update Nix packages")
    parser.add_argument("--package", help="Specify a single package to update")
    # 添加可选的 nix-update 参数
    parser.add_argument(
        "--commit", action="store_true", help="Pass --commit to nix-update"
    )
    parser.add_argument("--test", action="store_true", help="Pass --test to nix-update")
    parser.add_argument(
        "--build", action="store_true", help="Pass --build to nix-update"
    )
    # 允许任意其他 nix-update 参数
    parser.add_argument(
        "extra_args", nargs="*", help="Additional arguments for nix-update"
    )
    args = parser.parse_args()

    pkgs_dir = "./pkgs"

    if not os.path.exists(pkgs_dir):
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
        # 如果指定了 --package，只更新指定包
        package_found = False
        for package_name, package_dir in packages:
            if package_name == args.package:
                update_package(package_name, package_dir, extra_args)
                package_found = True
                break
        if not package_found:
            print(f"Package {args.package} not found in pkgs directory")
    else:
        # 否则更新所有包
        print(f"Found {len(packages)} packages to update")
        for package_name, package_dir in packages:
            update_package(package_name, package_dir, extra_args)


if __name__ == "__main__":
    main()
