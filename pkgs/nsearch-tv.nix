# check the project at: <https://github.com/3timeslazy/nix-search-tv>
{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  fzf,
  gnused,
  gawk,
  xdg-utils,
  nix-search-tv,
  bash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nix-search-tv";
  version = "2.1.7";

  src = fetchFromGitHub {
    owner = "3timeslazy";
    repo = "nix-search-tv";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-TyniXPYrSy7m3+WxHKN/pXWVpG4UqwwC/RUMSLaQYRU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ bash ];

  propagatedBuildInputs = [
    fzf
    gnused
    gawk
    xdg-utils
  ];

  installPhase = ''
    runHook preInstall

    # Create bin directory
    mkdir -p $out/bin

    # Copy and modify the script
    cp nixpkgs.sh "$out/bin/nsearch-tv"

    # Replace "all ctrl-a" with "all alt-a"
    # sed -i 's/"all ctrl-a"/"all alt-a"/g' $out/bin/nsearch-tv

    # Make it executable
    chmod +x $out/bin/nsearch-tv

    # Wrap the script to ensure dependencies are available
    wrapProgram $out/bin/nsearch-tv \
      --prefix PATH : ${
        lib.makeBinPath [
          fzf
          gnused
          gawk
          nix-search-tv
          xdg-utils
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Interactive Nix package search with fzf";
    homepage = "https://github.com/3timeslazy/nix-search-tv";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.lonerOrz ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "nsearch-tv";
  };
})
