{ pkgs, ... }:

let
  pythonPackages = pkgs.python3.withPackages (
    ps: with ps; [
      uv
      requests
      pyquery
      gpustat
      ruff
      pygobject3
    ]
  );
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pyright
  ];

  buildInputs = [
    pythonPackages
    pkgs.gobject-introspection
  ];

  env = {
    PYTHONBREAKPOINT = "ipdb.set_trace";
    GI_TYPELIB_PATH = "${pkgs.glib}/lib/girepository-1.0:${pkgs.libsoup_3}/share/gir-1.0:${pkgs.gobject-introspection}/lib/girepository-1.0:${pkgs.libical}/lib/girepository-1.0:${pkgs.evolution-data-server}/lib/girepository-1.0";
  };

  shellHook = ''
    echo "🐍 Python environment loaded"
  '';
}
