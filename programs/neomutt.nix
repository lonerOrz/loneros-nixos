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
    cyrus-sasl-xoauth2 # cyrus-sasl 的 XOAUTH2 支持
    w3m # HTML 邮件
  ];

  environment.sessionVariables = {
    NEOMUTT_SCRIPTS = "${pkgs.neomutt}/share/neomutt/";
    SASL_PATH = "/run/current-system/sw/lib/sasl2";
  };
}
