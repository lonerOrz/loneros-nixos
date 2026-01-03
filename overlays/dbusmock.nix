# done https://github.com/NixOS/nixpkgs/pull/471047
# waiting-pr https://github.com/NixOS/nixpkgs/pull/471043
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      python-dbusmock = python-prev.python-dbusmock.overridePythonAttrs (oldAttrs: rec {
        version = "0.37.2";

        src = prev.fetchFromGitHub {
          owner = "martinpitt";
          repo = "python-dbusmock";
          tag = version;
          hash = "sha256-Q149NcbpbIgXCd7WujALC9I9vAM/tZh+enTJh0d84Kg=";
        };
      });
    })
  ];

  polkit = prev.polkit.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        name = "dbusmock-0.37.patch";
        url = "https://github.com/polkit-org/polkit/commit/690e6972ffe30473dacbfaa81158f5507cef99f6.patch";
        hash = "sha256-0LhwJLfohqVkCT1fIDRe97+vPbo4sej0YRBFTfKKTH4=";
      })
    ];
  });
}
