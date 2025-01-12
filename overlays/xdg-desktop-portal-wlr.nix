self: super: {
  xdg-desktop-portal-wlr = super.stdenv.mkDerivation rec {
    pname = "xdg-desktop-portal-wlr";
    version = "0.7.1";  # 保持版本号不变，可以作为标识

    # 修改 src，指定为 Enovale/xdg-desktop-portal-wlr@11817f9
    src = super.fetchFromGitHub {
      owner = "Enovale";
      repo = pname;
      rev = "11817f90de8903a32b9ea0add3bb3a478c6635e5";
      #sha256 = "19k5kk4dggr6jchd2wygbjszqsvnk3ls0hqrfbnmcgl03faibgyx";
      sha256 = "0j8sf13c060l37cwvn4m55fdgm18lxjba4hcjqylrq5hgcxkjfsf";
    };

    strictDeps = true;
    depsBuildBuild = [ super.pkg-config ];
    nativeBuildInputs = [
      super.meson
      super.ninja
      super.pkg-config
      super.scdoc
      super.wayland-scanner
      super.makeWrapper
    ];
    buildInputs = [
      super.inih
      super.libdrm
      super.libgbm
      super.pipewire
      super.systemd
      super.wayland
      super.wayland-protocols
      super.libxkbcommon
    ];

    mesonFlags = [
      "-Dsd-bus-provider=libsystemd"
      "-Dwerror=false"  # 禁用警告作为错误
    ];

    postInstall = ''
      wrapProgram $out/libexec/xdg-desktop-portal-wlr --prefix PATH ":" ${
        super.lib.makeBinPath [
          super.bash
          super.grim
          super.slurp
        ]
      }
    '';

    meta = with super.lib; {
      homepage = "https://github.com/Enovale/xdg-desktop-portal-wlr";
      description = "xdg-desktop-portal backend for wlroots";
      maintainers = with super.maintainers; [ minijackson ];
      platforms = platforms.linux;
      license = licenses.mit;
    };
  };
}

