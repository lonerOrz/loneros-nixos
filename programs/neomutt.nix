{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (neomutt.override {
      enableLua = true;
      enableZstd = true;
      enableSmimeKeys = true; # S/MIME 密钥支持
      withNotmuch = true; # 邮件索引集成
      withContrib = true; # 官方提供的贡献工具和脚本集合
    })
    isync
  ];

  environment.sessionVariables = {
    NEOMUTT_SCRIPTS = "${pkgs.neomutt}/share/neomutt/";
  };
}
