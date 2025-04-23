# 添加 electrcon 应用的环境变量和参数
self: super: 
  let
    sftname = "code-cursor"; # 软件名称
    cmdname = "cursor"; # 命令行名称
  in 
{
  "${sftname}-wrapper" = super.${sftname}.overrideAttrs (oldAttrs: {
    pname = "${sftname}-wrapper";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.makeWrapper ];

    postInstall = ''
      echo "Wrapping cursor binary..."
      if [ -f "$out/bin/${cmdname}" ]; then
        wrapProgram "$out/bin/${cmdname}" \
        --set ELECTRON_OZONE_PLATFORM_HINT auto \
        --set LIBGL_ALWAYS_INDIRECT 1 \
        --add-flags "--disable-gpu"
      else
        echo "Warning: $out/bin/${cmdname} not found!"
      fi
    '';
  });
}

