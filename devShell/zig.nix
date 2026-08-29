{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    zig
    zls # Zig Language Server
    lldb # Debugger
  ];

  buildInputs = with pkgs; [
    # C libraries for C-interop (if needed)
  ];

  env = {
    # Custom environment variables if needed
  };

  shellHook = ''
    echo "⚡ Zig environment loaded"
  '';
}
