self: super: {
  vscodium-wrapper = super.vscodium.overrideAttrs (oldAttrs: {
    pname = "vscodium-wrapper";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.makeWrapper ];

    postInstall = ''
      echo "Wrapping cursor binary..."

      # 确保目标存在
      if [ -f "$out/bin/codium" ]; then
        wrapProgram "$out/bin/codium" \
          --set ELECTRON_OZONE_PLATFORM_HINT auto \
          --set LIBGL_ALWAYS_INDIRECT 1 \
          --add-flags "--disable-gpu"
      else
        echo "Warning: $out/bin/codium not found!"
      fi
    '';
  });
}
