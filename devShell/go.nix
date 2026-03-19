{ pkgs, ... }:

pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      go_1_25
      gotools # goimports, godoc, etc.
      golangci-lint # https://github.com/golangci/golangci-lint
    ]
  );

  env = {
    GOPATH = "$HOME/.config/go";
  };

  shellHook = ''
    export PATH="$GOPATH/bin:$PATH"
    echo "🐹 Go environment loaded"
  '';
}
