self: super:

let
  sftname = "mihomo-party"; # 软件名称
  cmdname = "mihomo-party"; # 命令行名称
in
{
  ${sftname} = super.callPackage ../pkgs/mihomo/package.nix { };

  "${sftname}-wrapper" = self.${sftname}.overrideAttrs (oldAttrs: {
    pname = "${sftname}-wrapper";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ super.makeWrapper ];

    postInstall = ''
      echo "Wrapping ${cmdname} binary..."
      if [ -f "$out/bin/${cmdname}" ]; then
        wrapProgram "$out/bin/${cmdname}" \
          --set ELECTRON_OZONE_PLATFORM_HINT auto \
          --set NIXOS_OZONE_WL 1 \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=x11 --enable-wayland-ime --use-gl=swiftshader --disable-gpu"
      else
        echo "Warning: $out/bin/${cmdname} not found!"
      fi
    '';
  });
}
