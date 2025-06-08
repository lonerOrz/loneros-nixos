{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  yt-dlp,
}:
rustPlatform.buildRustPackage rec {
  pname = "mpv-handler";
  version = "0.3.16";

  src = fetchFromGitHub {
    owner = "akiirui";
    repo = "mpv-handler";
    rev = "v${version}";
    sha256 = "sha256-RpfHUVZmhtneeu8PIfxinYG3/groJPA9QveDSvzU6Zo=";
  };

  cargoHash = "sha256-FrE1PSRc7GTNUum05jNgKnzpDUc3FiS5CEM18It0lYY=";
  useFetchCargoVendor = true;

  nativeBuildInputs = [makeWrapper];

  postInstall = ''
    mkdir -p $out/share/applications
    cp ${src}/share/linux/mpv-handler.desktop $out/share/applications/
    cp ${src}/share/linux/mpv-handler-debug.desktop $out/share/applications/
    cp ${src}/share/linux/config.toml $out/share/

    wrapProgram $out/bin/mpv-handler \
      --prefix PATH : ${lib.makeBinPath [mpv yt-dlp]}
  '';

  meta = with lib; {
    description = "Play website videos and songs with mpv & yt-dlp.";
    homepage = "https://github.com/akiirui/mpv-handler";
    license = licenses.mit;
    maintainers = with maintainers; []; # 添加你的 GitHub 用户名，如果打算提交
    platforms = platforms.linux;
  };
}
