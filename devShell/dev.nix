{ pkgs, ... }:
pkgs.mkShell {
  buildInputs =
    # --- Node.js/JS ---
    (with pkgs; [
      nodejs_22
      yarn
      pnpm
      eslint_d
    ])
    ++
      # --- Python ---
      (with pkgs; [
        python312
        pyright
      ])
    ++ (with pkgs.python312Packages; [
      uv
      requests
      pyquery
      gpustat
      ruff
    ])
    ++
      # --- C/C++ ---
      (with pkgs; [
        gcc
        gdb
        clang
        lldb
        cmake
      ])
    ++
      # --- Lua ---
      (with pkgs; [
        lua5_4_compat
        luarocks
      ])
    ++
      # --- Rust ---
      (with pkgs; [
        rust-analyzer
        rustfmt
        clippy
      ]);

  shellHook = ''
    echo "🛠️ Welcome to the Dev Shell"
    export PYTHONBREAKPOINT=ipdb.set_trace
  '';
}
