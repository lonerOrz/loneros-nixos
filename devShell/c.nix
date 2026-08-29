{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    gcc
    clang-tools
    cmake
    ninja
    gdb
    codespell
    conan
    cppcheck
    doxygen
    gtest
    lcov
    vcpkg
    vcpkg-tool
    pkg-config
  ];

  buildInputs = with pkgs; [
    zlib
    openssl
  ];

  env = {
    LIBRARY_PATH = "${pkgs.zlib}/lib:${pkgs.openssl}/lib";
    CPATH = "${pkgs.zlib.dev}/include:${pkgs.openssl.dev}/include";
  };

  shellHook = ''
    echo "🛠️ C/C++ environment loaded"
  '';
}
