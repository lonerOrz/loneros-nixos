#waiting-pr https://github.com/NixOS/nixpkgs/pull/495124
final: prev:

let
  pythonForConan = prev.python3.override {
    packageOverrides = pyFinal: pyPrev: {
      patch-ng = pyPrev.patch-ng.overridePythonAttrs (_: {
        version = "1.18.1";
        src = prev.fetchPypi {
          pname = "patch-ng";
          version = "1.18.1";
          hash = "sha256-Uv1G7kb2yGZ2kmgsH9cTTtxlotLQhOvsHSlaYIf8ApE=";
        };
      });
    };
  };
in
{
  conan = prev.conan.override {
    python3Packages = pythonForConan.pkgs;
  };
}
