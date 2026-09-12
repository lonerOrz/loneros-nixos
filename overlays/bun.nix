final: prev:
let
  version = "1.4.2";

  sources = {
    "aarch64-darwin" = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
      hash = "sha256-kJh6OhbX21VtiGrD1VHnttPt8KHPQ6yu1iLoZ2vh0S8=";
    };

    "aarch64-linux" = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
      hash = "sha256-VDKLvC2cjgyfiSxUTWbFeoO4QTnjSQnl7oF1jxrI/ac=";
    };

    "x86_64-linux" = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
      hash = "sha256-xngEDxT+BEDrg503y9DOTAUaMtpygGrJfeamqra/co8=";
    };
  };
in
{
  bun = prev.bun.overrideAttrs (old: {
    inherit version;

    src = sources.${prev.stdenv.hostPlatform.system};

    passthru = old.passthru // {
      inherit sources;
    };
  });
}
