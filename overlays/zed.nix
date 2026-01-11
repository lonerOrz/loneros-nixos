# waiting-pr https://github.com/NixOS/nixpkgs/pull/478690
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
      {
        # 使用 cargo-nextest 代替 cargo test
        useNextest = true;

        # 明确移除上游为 cargo test 写的 skip 规则
        checkFlags = [ ];
      }
  );
}
