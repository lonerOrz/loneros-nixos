self: prev:
let
  # https://github.com/NixOS/nixpkgs/pull/401421
  libplacebo-mpv = prev.libplacebo.overrideAttrs (old: {
    version = "7.349.0";
    src = prev.fetchFromGitLab {
      domain = "code.videolan.org";
      owner = "videolan";
      repo = "libplacebo";
      rev = "v7.349.0";
      hash = "sha256-mIjQvc7SRjE1Orb2BkHK+K1TcRQvzj2oUOCUT4DzIuA=";
    };
  });
  mpv-unwrapped-custom = prev.mpv-unwrapped.override {
    libplacebo = libplacebo-mpv;
  };
  mpv-wrapper = prev.mpv.override {
    # mpv = mpv-unwrapped-custom; # pr 401421: 已经解决
    scripts = with prev.mpvScripts; [
      mpris
      autoload
    ];
  };
in
{
  mpv = mpv-wrapper;
}
