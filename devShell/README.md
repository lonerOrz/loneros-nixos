# DevShell

模块化开发环境配置，基于 `inputsFrom` 自动组合。

---

## 架构

```
┌─────────────────────────────────────────────────────────────┐
│                      default.nix                            │
│                                                             │
│  shells = {                                                 │
│    node       = [ "node" ];                                 │
│    python     = [ "python" ];                               │
│    python-cuda = [ "python" "cuda" ];                       │
│  }                                                          │
│                                                             │
│  buildShell name modules:                                   │
│    1. 加载模块 → modules                                    │
│    2. 检查修复文件 → custom (可选)                          │
│    3. 合并 → inputsFrom = modules ++ custom.inputsFrom      │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            ↓                               ↓
┌───────────────────────┐       ┌───────────────────────────────┐
│    基础模块            │       │    可选修复文件                │
│    <name>.nix         │       │    <组合名>.nix               │
│                       │       │                               │
│  { pkgs }:            │       │  { pkgs }:                    │
│  pkgs.mkShell {       │       │  {                            │
│    buildInputs = [...];       │    packages = [...];          │
│    env = {...};       │       │    env = {...};               │
│    shellHook = ''...'';       │    shellHook = ''...'';       │
│  }                    │       │  }                            │
└───────────────────────┘       └───────────────────────────────┘
            │                               │
            └───────────────┬───────────────┘
                            ↓
            ┌───────────────────────────────────┐
            │         最终 DevShell              │
            │                                   │
            │  pkgs.mkShell {                   │
            │    inputsFrom = modules ++        │
            │                 custom.inputsFrom │
            │    buildInputs = custom.packages; │
            │    env = custom.env;              │
            │    shellHook = custom.shellHook;  │
            │  }                                │
            └───────────────────────────────────┘
```

---

## 用法

### 进入开发环境

```bash
# 默认 shell (node + python + c + rust + lua + go)
nix develop .#devShells.x86_64-linux.default

# 特定 shell
nix develop .#devShells.x86_64-linux.node
nix develop .#devShells.x86_64-linux.python-cuda
```

---

## 创建基础模块

```nix
# mylang.nix
{ pkgs }:

pkgs.mkShell {
  buildInputs = with pkgs; [ mylang mylang-lsp ];

  env = {
    MYLANG_HOME = "$HOME/.mylang";
  };

  shellHook = ''
    export PATH="$MYLANG_HOME/bin:$PATH"
    echo "MyLang ready"
  '';
}
```

---

## 组合模块

在 `default.nix` 的 `shells` 中添加：

```nix
shells = {
  mylang-full = [ "mylang" "cuda" ];
};
```

👉 自动使用 `inputsFrom` 组合，无需额外文件。

---

## 修复环境冲突（可选）

如果组合后环境变量冲突，创建修复文件：

```nix
# mylang-cuda.nix
{ pkgs }:

{
  shellHook = ''
    export PYTHONPATH="${pkgs.python3.sitePackages}:$PYTHONPATH"
  '';
}
```

👉 文件名必须与组合 shell 同名。

---

## 可用 Shell

| Shell         | 模块                           | 说明           |
| ------------- | ------------------------------ | -------------- |
| `default`     | node, python, c, rust, lua, go | 全功能         |
| `dev`         | node, python                   | 轻量           |
| `cuda`        | cuda                           | CUDA（unfree） |
| `python-cuda` | python, cuda                   | Python + CUDA  |

---

## 常见问题

**什么时候需要修复文件？**

当组合后环境变量不对时：

```bash
nix develop .#devShells.x86_64-linux.python-cuda
echo $PYTHONPATH  # 检查
```

如果不对，创建 `<shell-name>.nix` 修复。

**为什么不用 `env merge`？**

`inputsFrom` 会自动处理 PATH、LD_LIBRARY_PATH、hooks，手动 merge 无法覆盖。
