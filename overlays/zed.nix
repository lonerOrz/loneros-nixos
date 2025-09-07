final: prev: {
  zed-editor = prev.zed-editor.overrideAttrs (
    old:
    if old.version == "0.202.5" then
      {
        src = final.fetchFromGitHub {
          owner = "zed-industries";
          repo = "zed";
          rev = "v0.202.5";
          sha256 = "sha256-Q7Ord+GJJcOCH/S3qNwAbzILqQiIC94qb8V+JkzQqaQ=";
        };
      }
    else
      { }
  );
}
