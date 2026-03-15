# done https://github.com/NixOS/nixpkgs/pull/497880
final: prev: {
  python3Packages = prev.python3Packages.overrideScope (
    pyFinal: pyPrev: {
      pelican = pyPrev.pelican.overridePythonAttrs (old: {
        pytestFlags = (old.pytestFlags or [ ]) ++ [
          "-Wignore::PendingDeprecationWarning"
        ];
      });
    }
  );
}
