{pkgs, ...}: {
  dev = pkgs.mkShell {
    buildInputs =
      # --- Node.js/JS 工具 ---
      (with pkgs; [
        nodejs_22
        node2nix
      ])
      ++ (with pkgs.nodePackages; [
        yarn
        pnpm
        eslint_d
      ])
      ++
      # --- Python 工具 ---
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
      # --- C/C++ 工具 ---
      (with pkgs; [
        gcc
        gdb
        clang
        lldb
        cmake
      ])
      ++
      # --- Lua 工具 ---
      (with pkgs; [
        lua5_4_compat
        luarocks
      ]);

    shellHook = ''
      echo "🛠️ Welcome to the Dev Shell"
      export PYTHONBREAKPOINT=ipdb.set_trace
    '';
  };
}
