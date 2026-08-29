{ pkgs, ... }:

let
  dotnetPkg =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
    ];
in
pkgs.mkShell {
  nativeBuildInputs = [
    dotnetPkg
    pkgs.powershell
  ];

  buildInputs = with pkgs; [
    openssl
    zlib
  ];

  env = {
    DOTNET_ROOT = "${dotnetPkg}/share/dotnet";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_WORKLOAD_AUTO_INSTALL = "0";
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE = "1";
  };

  shellHook = ''
    export PATH="$PATH:$HOME/.dotnet/tools"
    echo "🧩 .NET environment loaded"
  '';
}
