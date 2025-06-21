# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/issues/4037
self: super: {
  papirus-icon-theme = super.papirus-icon-theme.overrideAttrs (old: {
    version = "20250201";
    src = super.fetchFromGitHub {
      owner = "PapirusDevelopmentTeam";
      repo = "papirus-icon-theme";
      rev = "20250201";
      hash = "sha256-E2SpGAMsFfB64axDzUgVOZZwHDyPVbZjEvY4fJzRyUQ=";
    };
  });
}
