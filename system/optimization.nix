{
  config,
  stable,
  ...
}:
{
  boot.kernelParams = [ "intel_pstate=active" ];
  # - `intel_pstate=active`：启用 Intel P-State 驱动，并设置为 `active` 模式
  # - 该模式通常适用于 Intel CPU，可提高性能和功耗管理效率

  services = {
    auto-cpufreq.enable = true; # - 自动优化 CPU 频率和电源管理
    thermald.enable = true; # - Intel 官方的温控服务，可防止 CPU 过热
  };

  environment.systemPackages = with stable; [
    lenovo-legion # Lenovo Legion 系列笔记本的额外支持工具
  ];

  powerManagement = {
    enable = true; # 启用电源管理
    cpuFreqGovernor = "powersave"; # - `schedutil`：基于 CPU 任务负载动态调整频率
    # - 通常比 `performance` 和 `powersave` 更智能，适合大多数场景
  };

  zramSwap = {
    enable = true; # 启用 ZRAM 交换空间（在内存中创建压缩 swap）
    priority = 100; # 设置 ZRAM swap 优先级（高于物理 swap）
    memoryPercent = 30; # 使用总内存的 30% 作为 ZRAM 交换空间
    swapDevices = 1; # 仅创建一个 ZRAM 交换设备
    algorithm = "zstd"; # 使用 `zstd` 压缩算法（高压缩比 & 低 CPU 负担）
  };
}
