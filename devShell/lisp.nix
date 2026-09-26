{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    guile
    # raco pkg install --auto --no-docs racket-langserver fmt syntax-color-lib compatibility-lib
    racket-minimal
  ];

  env = {
    GUILE_AUTO_COMPILE = "0"; # 禁止在临时目录静默生成编译缓存
  };

  shellHook = ''
    export PATH="$HOME/.local/share/racket/$(racket -e '(display (version))')/bin:$PATH"
    echo "λ Scheme/Racket dev environment loaded"
  '';
}
