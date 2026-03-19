{ pkgs, ... }:

let
  # CUDA toolkit only - driver comes from system
  cudaToolkit = pkgs.cudatoolkit;
in

pkgs.mkShell {
  # Build toolchain
  buildInputs = with pkgs; [
    # CUDA core
    cudatoolkit

    # Build tools
    stdenv.cc
    binutils
    gnumake
    autoconf
    m4
    gperf

    # VCS and network
    git
    gitRepo
    curl
    gnupg
    unzip

    # X11 / OpenGL (for graphics interop)
    freeglut
    libGLU
    libx11
    libxext
    libxi
    libxmu
    libxrandr
    libxv

    # System utilities
    procps
    ncurses5
    util-linux
    zlib
  ];

  env = {
    EXTRA_LDFLAGS = "-L/lib";
    EXTRA_CCFLAGS = "-I/usr/include";
  };

  shellHook = ''
    export CUDA_PATH="${cudaToolkit}"
    export CUDA_HOME="$CUDA_PATH"
    export CUDA_ROOT="$CUDA_PATH"
    export EXTRA_LDFLAGS="-L/lib -L$CUDA_PATH/lib64 $EXTRA_LDFLAGS"
    export EXTRA_CCFLAGS="-I/usr/include -I$CUDA_PATH/include $EXTRA_CCFLAGS"
    export CMAKE_PREFIX_PATH="$CUDA_PATH:$CMAKE_PREFIX_PATH"
    export PKG_CONFIG_PATH="$CUDA_PATH/lib64/pkgconfig:$CUDA_PATH/lib/pkgconfig:$PKG_CONFIG_PATH"
    export PATH="$CUDA_PATH/bin:$PATH"

    echo "🚀 CUDA development environment loaded"
    echo "   CUDA_PATH: $CUDA_PATH"
    echo "   Using system NVIDIA driver (via /run/opengl-driver)"
    echo "   Using CUDA cache: cache.nixos-cuda.org"
  '';
}
