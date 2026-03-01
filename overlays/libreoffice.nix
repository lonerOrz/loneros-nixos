# waiting-pr https://github.com/NixOS/nixpkgs/pull/494721
final: prev: {
  libreoffice = prev.libreoffice.override {
    variant = "fresh";
  };
}
