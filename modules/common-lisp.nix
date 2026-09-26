# modules/common-lisp.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.dev.common-lisp;
in
{
  options.modules.dev.common-lisp = {
    enable = mkEnableOption "Enable Common Lisp environment";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sbcl
      lispPackages.quicklisp
    ];

    # 强行把 ~/.sbclrc 迁移至 ~/.config/sbcl/rc
    environment.etc."sbclrc".text = ''
      (require :asdf)
      (setf sb-ext:*userinit-pathname-function*
            (lambda () (uiop:xdg-config-home #P"sbcl/rc")))
    '';
  };
}
