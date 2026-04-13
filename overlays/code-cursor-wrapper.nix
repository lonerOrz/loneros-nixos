self: super:
let
  sftname = "code-cursor";
  cmdname = "cursor";

  version = "3.0.16";
  hash = "sha256-dN8tFSppIpO/P0Thst5uaNzlmfWZDh0Y81Lx1BuSYt0=";

  fixedCursor = super.${sftname}.override {
    fetchurl =
      args:
      if args ? url && builtins.match "\.*/Cursor-${version}-x86_64\\\.AppImage" args.url != null then
        super.fetchurl (
          args
          // {
            inherit hash;
          }
        )
      else
        super.fetchurl args;
  };
in
{
  ${sftname} = fixedCursor;

  "${sftname}-wrapper" = fixedCursor.overrideAttrs (oldAttrs: {
    pname = "${sftname}-wrapper";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ super.makeWrapper ];

    postInstall = ''
      echo "Wrapping cursor binary..."
      if [ -f "$out/bin/${cmdname}" ]; then
        wrapProgram "$out/bin/${cmdname}" \
          --set ELECTRON_OZONE_PLATFORM_HINT auto \
          --set LIBGL_ALWAYS_INDIRECT 1 \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=x11 --enable-wayland-ime --disable-gpu"
      else
        echo "Warning: $out/bin/${cmdname} not found!"
      fi
    '';
  });
}
