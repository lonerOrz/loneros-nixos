self: super:
let
  sftname = "obsidian"; # 软件名称
  cmdname = "obsidian"; # 命令行名称
in
{
  "${sftname}-wrapper" = super.${sftname}.overrideAttrs (oldAttrs: {
    pname = "${sftname}-wrapper";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ super.makeWrapper ];

    postInstall = ''
      echo "Wrapping cursor binary..."
      if [ -f "$out/bin/${cmdname}" ]; then
        wrapProgram "$out/bin/${cmdname}" \
          --set ELECTRON_OZONE_PLATFORM_HINT auto \
          --set LIBGL_ALWAYS_INDIRECT 1 \
          --set XMODIFIERS "@im=fcitx" \
          --set GTK_IM_MODULE "fcitx" \
          --set QT_IM_MODULE "fcitx" \
          --set INPUT_METHOD "fcitx" \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime --disable-gpu"
      else
        echo "Warning: $out/bin/${cmdname} not found!"
      fi
    '';
  });
}
