{ pkgs, ... }:

pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      gcc
      clang-tools
      cmake
      codespell
      conan
      cppcheck
      doxygen
      gtest
      lcov
      vcpkg
      vcpkg-tool
    ]
    ++ (if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then [ ] else [ gdb ]);

  nativeBuildInputs = [ pkgs.pkg-config ];

  env = {
    LIBRARY_PATH = "${pkgs.zlib}/lib";
    CPATH = "${pkgs.zlib.dev}/include";
  };

  shellHook = ''
    echo "🛠️ C/C++ environment loaded"
  '';
}
