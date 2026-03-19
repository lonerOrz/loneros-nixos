{ pkgs }:

{
  shellHook = ''
    export PYTHONPATH="${pkgs.python3.sitePackages}:$PYTHONPATH"
    echo "🐍🚀 Python + CUDA DevShell ready"
  '';
}
