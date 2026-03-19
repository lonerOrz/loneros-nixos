{ pkgs }:

let
  python-packages = pkgs.python3.withPackages (
    ps: with ps; [
      uv
      requests
      pyquery # needed for hyprland-dots Weather script
      gpustat # gpu status
      ruff
      pygobject3
    ]
  );
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    python-packages
    pyright
    rubyPackages.gobject-introspection
  ];

  env = {
    PYTHONBREAKPOINT = "ipdb.set_trace";
  };

  shellHook = ''
    export GI_TYPELIB_PATH="${pkgs.glib}/lib/girepository-1.0:${pkgs.libsoup_3}/share/gir-1.0:${pkgs.gobject-introspection}/lib/girepository-1.0:${pkgs.libical}/lib/girepository-1.0:${pkgs.evolution-data-server}/lib/girepository-1.0"
    echo "🐍 Python environment loaded"
  '';
}
