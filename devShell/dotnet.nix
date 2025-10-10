{ pkgs }:

let
  # Select your .NET SDK version
  dotnetPkg =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
    ];
  allPackages =
    (with pkgs; [
      openssl
      zlib
      powershell
    ])
    ++ [ dotnetPkg ]
    ++ (with pkgs; [
      coreutils # ls, cat, mv, etc.
    ]);
in
{
  packages = allPackages;

  env = {
    DOTNET_ROOT = "${dotnetPkg}/share/dotnet";
    PATH = pkgs.lib.makeBinPath allPackages;
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_WORKLOAD_AUTO_INSTALL = "0";
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE = "1";
    NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
      with pkgs;
      [
        stdenv.cc.cc
        openssl
        zlib
      ]
    );
    NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";
  };

  shellHook = ''
    echo "🧩 C# environment loaded"
    echo ""
    echo "SDKs installed:"
    dotnet --list-sdks || true
    export PATH="$PATH:$HOME/.dotnet/tools"
  '';
}
