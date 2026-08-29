{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    go
    gotools
    golangci-lint
  ];

  env = {
    GOPATH = "$HOME/.config/go";
  };

  shellHook = ''
    export PATH="$GOPATH/bin:$PATH"
    echo "🐹 Go environment loaded"
  '';
}
