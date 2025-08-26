{
  lib,
  url ? "",
}:

let
  # 检查 URL 非空
  _checkUrl = if url == "" then throw "getRaw: url cannot be empty" else null;

  # 移除前缀
  prefixHttps = "https://github.com/";
  prefixHttp = "http://github.com/";
  withoutPrefix =
    if lib.strings.hasPrefix prefixHttps url then
      lib.strings.removePrefix prefixHttps url
    else if lib.strings.hasPrefix prefixHttp url then
      lib.strings.removePrefix prefixHttp url
    else
      throw "getRaw: URL must start with http://github.com/ or https://github.com/: ${url}";

  # 拆分路径
  parts = lib.strings.splitString "/" withoutPrefix;

  # 检查路径长度
  _checkParts =
    if builtins.length parts < 5 then
      throw "getRaw: URL does not match https://github.com/<user>/<repo>/blob/<branch>/<path>: ${url}"
    else
      null;

  user = builtins.elemAt parts 0;
  repo = builtins.elemAt parts 1;
  blob = builtins.elemAt parts 2; # "blob"
  branch = builtins.elemAt parts 3;
  path = lib.strings.concatStringsSep "/" (lib.lists.drop 4 parts);

  # 检查第三段是 "blob"
  _checkBlob =
    if blob != "blob" then throw "getRaw: URL must contain '/blob/' before branch: ${url}" else null;
in
"https://raw.githubusercontent.com/${user}/${repo}/${branch}/${path}"
