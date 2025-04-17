# 添加 electrcon 应用的环境变量和参数
self: super: {
  code-cursor-wrapper = super.code-cursor.overrideAttrs (oldAttrs: {
    pname = "code-cursor-wrapper";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.makeWrapper ];

    postInstall = ''
      echo "Wrapping cursor binary..."

      # 确保目标存在
      if [ -f "$out/bin/cursor" ]; then
        wrapProgram "$out/bin/cursor" \
          --set ELECTRON_OZONE_PLATFORM_HINT auto \
          --set LIBGL_ALWAYS_INDIRECT 1 \
          --add-flags "--disable-gpu"
      else
        echo "Warning: $out/bin/cursor not found!"
      fi
    '';
  });
}
