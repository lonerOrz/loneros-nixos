{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    libinput
    # libinput-gestures  # 仅在 X11 且需要手势时启用
  ];

  services.libinput = {
    enable = true;

    # 触摸板
    touchpad = {
      # 减慢移动速度防止乱飞
      accelSpeed = "-0.5";
      accelProfile = "adaptive";

      # 打字时禁用触摸板
      disableWhileTyping = true;

      # 自然滚动
      naturalScrolling = true;
      # 双指滚动
      scrollMethod = "twofinger";
      horizontalScrolling = true;

      # 禁用轻触点击
      tapping = false;
      tappingDragLock = true;
      tappingButtonMap = "lrm";

      # 禁用中键模拟
      middleEmulation = false;

      # 右手模式
      leftHanded = false;
    };

    mouse = {
      accelSpeed = "-0.3";
      accelProfile = "adaptive";

      naturalScrolling = false;
      horizontalScrolling = true;

      middleEmulation = false;
      leftHanded = false;
    };
  };
}
