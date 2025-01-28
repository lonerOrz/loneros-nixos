self: super: {
  spicetify-nix = super.stdenv.mkDerivation rec {
    pname = "spicetify-nix";

    src = super.fetchFromGitHub {
      owner = "RANKSHANK";
      repo = pname;
      rev = "a040632a0717a3f97bd7bcd45a44d61c927bcc7e";
      hash = "sha256-NrluitLnc1DX+rO9wpIyTKfCCFsODUlVjN6WIU0UPog=";
    };
  };
}
