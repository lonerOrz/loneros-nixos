self: super:
let
  pkgs = super;
  sftname = "vscodium"; # 原包名
  cmdname = "codium"; # CLI 可执行文件名
  bash = super.bash; # 系统 bash
  # bgFile = builtins.fetchurl {
  #   url = "https://raw.githubusercontent.com/lonerOrz/loneros-dots/main/wallpapers/Anime-Room.png";
  #   sha256 = "sha256-dOtbav0HQy1iex/I1oaeYj3i6LCa9alE8d9U2KTuD9s=";
  # };
  wallpapersRepo = pkgs.fetchFromGitHub {
    owner = "lonerOrz";
    repo = "loneros-dots";
    rev = "main";
    sha256 = "1p2jjfb88155rglyqaccpvfm11px0lw7iff14zifslfzxmnfkpwf";
  };
  bgFile = "${wallpapersRepo}/wallpapers/loner/miles-catppuccin.jpg";
in
{
  "${sftname}-wrapper" = super.${sftname}.overrideAttrs (old: {
    pname = "${sftname}-wrapper";

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      super.makeWrapper
      super.nodePackages.asar
      super.coreutils # 确保有 base64
    ];

    postPatch =
      (old.postPatch or "")
      + ''
              echo "► 解包 .asar 并修正路径 …"

              packed="resources/app/node_modules.asar"
              [ ! -f "$packed" ] && packed="resources/app/app.asar"
              unpacked="resources/app/node_modules"

              if [ -f "$packed" ]; then
                asar extract "$packed" "$unpacked"

                substituteInPlace "$unpacked/@vscode/sudo-prompt/index.js" \
                  --replace "/usr/bin/pkexec"  "/run/wrappers/bin/pkexec" \
                  --replace "/bin/bash"        "${bash}/bin/bash"        \
                  --replace "/usr/bin/kdesudo" "/run/wrappers/bin/sudo"

                rm -f "$packed"
              fi

              # ripgrep 可执行
              [ -f resources/app/node_modules/vscode-ripgrep/bin/rg ] && \
                chmod +x resources/app/node_modules/vscode-ripgrep/bin/rg || true


              ####################################################################
              # 生成 Base64 串
              ####################################################################
              b64=$(base64 -w0 ${bgFile})

              ####################################################################
              # 1) 追加 / 更新 CSS 补丁
              ####################################################################
              css="resources/app/out/vs/workbench/workbench.desktop.main.css"
              [ -f "$css.orig" ] || cp "$css" "$css.orig"

              cat "$css.orig" > "$css" && cat >>"$css" <<EOF

        html, body{
          background:transparent !important;   /* ← 把主题色清空 */
        }
        /*ext-backgroundCover-start*/
        body::before{
          content:"";
          position:fixed;
          inset:0;
          width:100vw;
          height:100vh;
          background:url("data:image/png;base64,$b64") center/cover no-repeat;
          opacity:.3;
          filter:blur(0px);
          pointer-events:none;
          z-index:2147483647 !important;
        }
        /*ext-backgroundCover-end*/
        EOF


              ####################################################################
              # 2) 追加 / 更新 JS 注入段
              ####################################################################
              js="resources/app/out/vs/workbench/workbench.desktop.main.js"
              jsStart="/*ext-backgroundCover-js-start*/"
              jsEnd="/*ext-backgroundCover-js-end*/"

              # 删旧段（注意 \$ 转义，避免被 Nix 提前处理）
              perl -0777 -pe "s/\\$jsStart[\\s\\S]*?\\$jsEnd//g" "$js" >"$js.tmp" && mv "$js.tmp" "$js"

              # 追加新段
              printf '%s\n' "$jsStart" \
        'try {' \
        '  const bcStyle = document.createElement("style");' \
        '  bcStyle.textContent = `' \
        '  body::before{' \
        '    content:"";position:fixed;inset:0;width:100vw;height:100vh;' \
        "    background:url(data:image/png;base64,$b64) center/cover no-repeat;" \
        '    opacity:.3;filter:blur(0px);pointer-events:none;z-index:-1;' \
        '  }`;' \
        '  document.head.appendChild(bcStyle);' \
        '} catch(e) { console.error("backgroundCover inject error:", e); }' \
        "$jsEnd" >>"$js"
      '';

    postInstall =
      (old.postInstall or "")
      + ''
        echo "► wrap codium binary …"
        if [ -f "$out/bin/${cmdname}" ]; then
          wrapProgram "$out/bin/${cmdname}" \
            --set ELECTRON_OZONE_PLATFORM_HINT auto \
            --set LIBGL_ALWAYS_INDIRECT 1     \
            --add-flags "--disable-gpu"
        fi
      '';
  });
}
