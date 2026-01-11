# done https://github.com/NixOS/nixpkgs/pull/476347
final: prev: {
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    # electron builds must be writable
    preBuild =
      prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
        cp -r ${prev.electron.dist}/Electron.app .
        chmod -R u+w Electron.app
      ''
      + prev.lib.optionalString prev.stdenv.hostPlatform.isLinux ''
        cp -r ${prev.electron.dist} electron-dist
        chmod -R u+w electron-dist
      '';

    buildPhase = ''
      runHook preBuild

      pnpm build
      pnpm exec electron-builder \
        --dir \
        -c.asarUnpack="**/*.node" \
        -c.electronDist=${if prev.stdenv.hostPlatform.isDarwin then "." else "electron-dist"} \
        -c.electronVersion=${prev.electron.version}

      runHook postBuild
    '';
  });
}
