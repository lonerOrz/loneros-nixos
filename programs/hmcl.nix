{
  pkgs,
  ...
}:
let
  customhmcl = pkgs.hmcl.override {
    minecraftJdks = with pkgs; [
      jdk8
      jdk11
      jdk17
      jdk21
    ];
  };
in
{
  # Minecraft 启动器
  environment.systemPackages = [
    customhmcl
  ];
}
