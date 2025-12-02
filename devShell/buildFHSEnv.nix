# 这只是一个完整的 buildFHSEnv 示例，展示了所有可用选项的使用
{
  pkgs ? import <nixpkgs> { },
}:

(pkgs.buildFHSEnv {
  # 环境名称
  name = "full-example-env";

  # 环境 pname
  pname = "full-example";

  # 环境版本
  version = "1.0";

  # 包装器可执行文件名称
  executableName = "full-example-run";

  # 为主机架构安装的软件包（库和二进制文件）
  targetPkgs =
    pkgs:
    (with pkgs; [
      udev
      alsa-lib
      bash
    ])
    ++ (with pkgs.xorg; [
      libX11
      libXcursor
      libXrandr
    ]);

  # 为主机支持的所有架构安装的软件包（默认仅安装库）
  multiPkgs =
    pkgs:
    (with pkgs; [
      udev
      alsa-lib
    ]);

  # 是否在 64 位环境下将 32 位 multiPkgs 安装到 FHSEnv
  multiArch = true;

  # 额外构建命令，用于最终确定目录结构
  extraBuildCommands = ''
    echo "执行额外构建命令..."
  '';

  # 仅在多库架构上执行的额外构建命令
  extraBuildCommandsMulti = ''
    echo "多库架构的额外构建命令..."
  '';

  # 额外输出需要链接到目标和多架构软件包
  extraOutputsToInstall = [
    "out"
    "doc"
  ];

  # 使用运行脚本完成派生过程需要执行的额外命令
  extraInstallCommands = ''
    echo "执行额外安装命令..."
  '';

  # 要在沙箱内执行的命令，默认 bash
  runScript = "bash";

  # 沙箱内 /etc/profile 的可选脚本
  profile = ''
    export EXAMPLE_ENV=1
  '';
}).env
