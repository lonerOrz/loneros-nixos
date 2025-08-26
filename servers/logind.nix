{
  services.logind.settings.Login = {
    # 合盖系统进行休眠
    HandleLidSwitch = "lock";

    # 有其他显示器连接时合盖不执行任何操作
    HandleLidSwitchDocked = "ignore";

    # Idle 动作
    IdleAction = "suspend";
    IdleActionSec = "1min";

    # 如果需要自定义外接电源行为，可以加上：
    # HandleLidSwitchExternalPower = "ignore"; # 默认跟 HandleLidSwitch 一样
  };
}
