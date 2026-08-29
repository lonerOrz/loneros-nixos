{ pkgs, ... }:

let
  cudaToolkit = pkgs.cudatoolkit;
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    stdenv.cc
    binutils
    gnumake
    autoconf
    m4
    gperf
    git
    gitRepo
    curl
    gnupg
    unzip
    procps
    ncurses5
    util-linux
  ];

  buildInputs = with pkgs; [
    cudatoolkit
    freeglut
    libGLU
    libx11
    libxext
    libxi
    libxmu
    libxrandr
    libxv
    zlib
  ];

  env = {
    CUDA_PATH = "${cudaToolkit}";
    CUDA_HOME = "${cudaToolkit}";
    CUDA_ROOT = "${cudaToolkit}";
    EXTRA_LDFLAGS = "-L/lib -L${cudaToolkit}/lib64";
    EXTRA_CCFLAGS = "-I/usr/include -I${cudaToolkit}/include";
    CMAKE_PREFIX_PATH = "${cudaToolkit}";
    PKG_CONFIG_PATH = "${cudaToolkit}/lib64/pkgconfig:${cudaToolkit}/lib/pkgconfig";
  };

  shellHook = ''
    export PATH="$CUDA_PATH/bin:$PATH"
    echo "🚀 CUDA environment loaded"
  '';
}
