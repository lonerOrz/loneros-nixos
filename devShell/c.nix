{ pkgs, ... }:
{
  packages = with pkgs; [
    gcc
    gdb
    clang
    lldb
    cmake
  ];
  nativeBuildInputs = [ pkgs.pkg-config ];
  env = {
    LIBRARY_PATH = "${pkgs.zlib}/lib";
    CPATH = "${pkgs.zlib.dev}/include";
  };
  shellHook = ''
    echo "🛠️ C/C++ environment loaded"
  '';
}
