{ lib }:
# 将嵌套 attrset 转换为 "a/b/c" = leaf 形式
# 用于 sops-nix 等需要 flatten secrets 的场景
#
# 例如：
#   flattenAttrset "/" { a = { b = { c = 1; d = 2; }; }; x = { y = 3; }; }
#   => { "a/b" = { c = 1; d = 2; }; "x" = { y = 3; }; }
sep: attrs:
let
  # 判断是否是 leaf attrset（所有值都不是 attrset）
  isLeafAttrset =
    node:
    builtins.isAttrs node && builtins.all (k: !builtins.isAttrs node.${k}) (builtins.attrNames node);

  collect =
    prefix: node:
    if isLeafAttrset node then
      [
        {
          name = prefix;
          value = node;
        }
      ]
    else if builtins.isAttrs node then
      lib.concatMap (
        key:
        let
          newPrefix = if prefix == "" then key else "${prefix}${sep}${key}";
        in
        collect newPrefix node.${key}
      ) (builtins.attrNames node)
    else
      [ ];
in
lib.listToAttrs (collect "" attrs)
