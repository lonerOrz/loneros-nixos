#https://github.com/NixOS/nixpkgs/issues/425335
final: prev: {
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (_python-final: python-prev: {
      # NOTE: could patch nixpkgs for broken grammars using
      # `applyPatches` + <https://github.com/dtomvan/nixpkgs/commit/f0a1b58b7c882690540b893cd27422dfbf7c2ce4.patch>
      tree-sitter =
        let
          version = "0.24.0";
        in
        python-prev.tree-sitter.overridePythonAttrs {
          inherit version;
          src = final.fetchPypi {
            inherit version;
            pname = "tree-sitter";
            hash = "sha256-q9la9lyi9Pfso1Y0M5HtZp52Tzd0i1NSlG8A9/x45zQ=";
          };
          # NOTE: not in the branch but was required on my system
          doCheck = false;
        };
      tree-sitter-rust =
        let
          version = "0.23.2";
        in
        python-prev.tree-sitter-rust.overridePythonAttrs {
          inherit version;
          src = final.fetchFromGitHub {
            owner = "tree-sitter";
            repo = "tree-sitter-rust";
            tag = "v${version}";
            hash = "sha256-aT+tlrEKMgWqTEq/NHh8Vj92h6i1aU6uPikDyaP2vfc=";
          };
        };
      textual = python-prev.textual.overridePythonAttrs {
        meta.broken = false;
      };
    })
  ];
}
