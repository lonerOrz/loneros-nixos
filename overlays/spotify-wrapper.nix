self: super:
let
  sftname = "spotify"; # 软件名称
  cmdname = "spotify"; # 命令行名称
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
          --set LIBVA_DRIVER_NAME nvidia \
          --set GBM_BACKEND nvidia-drm \
          --set __GLX_VENDOR_LIBRARY_NAME nvidia \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=x11 --enable-wayland-ime"
      else
        echo "Warning: $out/bin/${cmdname} not found!"
      fi
    '';
  });
}
