{
  services.libinput = {
    enable = true;

    # 通用稳定性优化
    # 这里的 additionalOptions 直接对应 libinput 属性
    touchpad.additionalOptions = {
      "libinput Palm Detection Enabled" = "1";
      "libinput Disable While Typing Enabled" = "1";
    };
    mouse.additionalOptions = {
      "libinput Accel Profile Enabled" = "1, 0";
    };

    # 触摸板
    touchpad = {
      # 减慢移动速度防止乱飞
      accelSpeed = -0.5;
      accelProfile = "adaptive";

      # 打字时禁用触摸板
      disableWhileTyping = true;

      # 自然滚动（Mac风格）
      naturalScrolling = true;

      # 双指滚动
      scrollMethod = "twofinger";
      horizontalScrolling = true;

      # 禁用轻触点击（防止乱飞）
      tapping = false;
      tappingDragLock = true;
      tappingButtonMap = "lrm";

      # 禁用中键模拟
      middleEmulation = false;

      # 右手模式
      leftHanded = false;

      # 平滑滚动与移动
      accelStepScroll = 0.05;
      accelStepMotion = 0.05;
    };

    # ---- 鼠标 ----
    mouse = {
      accelSpeed = -0.3;
      accelProfile = "adaptive";

      naturalScrolling = false;
      horizontalScrolling = true;

      middleEmulation = false;
      leftHanded = false;

      accelStepScroll = 0.05;
      accelStepMotion = 0.05;
    };
  };

  # 修复 MSFT0001:01 04F3:304B 跳动 bug
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Touchpad Jump Fix]
    MatchName=MSFT0001:01 04F3:304B
    AttrIgnoreTouchpadJumpEvents=true
  '';
}
