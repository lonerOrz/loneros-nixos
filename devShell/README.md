# DevShell

模块化开发环境配置。

**两个使用场景**：

1. **交互式开发环境** (`nix develop`)：使用 `inputsFrom` 继承
2. **系统环境** (`environment.systemPackages`)：提取 `buildInputs` + `env` 安装到系统

---

## 流程一：交互式开发环境 (`nix develop`)

```bash
nix develop .#devShells.x86_64-linux.default
nix develop .#devShells.x86_64-linux.python-cuda
```

### 流程图

```
┌─────────────────────────────────────────────────────────────────┐
│  1️⃣ default.nix：定义 shell 组合                                  │
│                                                                 │
│  shells = {                                                     │
│    default     = [ "node" "python" "c" "rust" "lua" "go" ];    │
│    python-cuda = [ "python" "cuda" ];                          │
│    ...                                                          │
│  };                                                             │
│                                                                 │
│  buildShell name modList pkgs':                                 │
│    modules = map (m: import ./${m}.nix) modList;               │
│    custom  = (可选) ./${name}.nix;                             │
│    return pkgs.mkShell {                                       │
│      inputsFrom = modules ++ custom.inputsFrom;                │
│      buildInputs = custom.packages;                            │
│      env = custom.env;                                         │
│      shellHook = custom.shellHook;                             │
│    };                                                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2️⃣ 模块文件：devShell/*.nix                                      │
│                                                                 │
│  { pkgs }:                                                      │
│  pkgs.mkShell {                                                 │
│    buildInputs = [ ... ];       # 被 inputsFrom 继承            │
│    nativeBuildInputs = [ ... ]; # 被 inputsFrom 继承            │
│    env = { KEY = "value"; };    # 被 inputsFrom 继承           │
│    shellHook = ''...'';         # 被 inputsFrom 继承           │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3️⃣ 最终 DevShell                                                │
│                                                                 │
│  pkgs.mkShell {                                                 │
│    inputsFrom = [ node.mkShell python.mkShell ... ];           │
│    # inputsFrom 自动继承所有 buildInputs, env, shellHook        │
│  }                                                              │
│                                                                 │
│  👉 nix develop 后自动拥有所有工具和环境变量                     │
└─────────────────────────────────────────────────────────────────┘
```

### 关键点

- `inputsFrom` 会自动合并所有依赖的 `buildInputs`, `nativeBuildInputs`, `env`, `shellHook`
- 无需手动 merge，Nix 自动处理依赖传递
- `shellHook` 会在进入 shell 时执行

---

## 流程二：系统环境 (`environment.systemPackages`)

```nix
# hosts/loneros/dev.nix
packagesForSystem = import ../../devShell/package.nix {
  inherit pkgs lib;
  modulesList = [ "node" "python" "c" "rust" "lua" "go" ];
};

environment.systemPackages = packagesForSystem.systemPackages;
environment.variables = packagesForSystem.environmentVariables;
```

### 流程图

```
┌─────────────────────────────────────────────────────────────────┐
│  1️⃣ hosts/loneros/dev.nix                                       │
│                                                                 │
│  devModules = [ "node" "python" "c" "rust" "lua" "go" ];       │
│  packagesForSystem = import ../../devShell/package.nix {       │
│    inherit pkgs lib;                                           │
│    modulesList = devModules;                                   │
│  };                                                            │
│                                                                 │
│  environment.systemPackages = [ openssl pkg-config ] ++        │
│    packagesForSystem.systemPackages;                           │
│  environment.variables = packagesForSystem.environmentVariables│
│    // { LD_LIBRARY_PATH = ... };                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2️⃣ package.nix：加载并提取数据                                   │
│                                                                 │
│  imported = map (name: import ./${name}.nix { inherit pkgs; }) │
│    modulesList;                                                 │
│                                                                 │
│  packages = flatten (map (m:                                    │
│    m.buildInputs ++ m.nativeBuildInputs) imported);            │
│  env = foldl' (acc: m: acc // (m.env or {})) {} imported;      │
│                                                                 │
│  return { systemPackages = packages;                            │
│           environmentVariables = env; }                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3️⃣ 模块文件：devShell/*.nix                                     │
│                                                                 │
│  { pkgs }:                                                      │
│  pkgs.mkShell {                                                 │
│    buildInputs = [ ... ];       # ← 提取到 systemPackages       │
│    nativeBuildInputs = [ ... ]; # ← 提取到 systemPackages       │
│    env = { KEY = "value"; };    # ← 提取到 environmentVariables │
│    shellHook = ''...'';         # ← 忽略 (仅 interactive 使用)  │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
```

### 关键点

- **只提取** `buildInputs`, `nativeBuildInputs`, `env`
- **忽略** `shellHook`（系统环境变量不能执行 shell 脚本）
- 包会被安装到系统 profile，全局可用
- 环境变量写入 `/etc/profile.d/`

---

## 两个流程对比

| 特性          | 流程一：`nix develop`              | 流程二：系统环境                 |
| ------------- | ---------------------------------- | -------------------------------- |
| 入口          | `default.nix`                      | `package.nix`                    |
| 使用方式      | `nix develop .#...`                | `environment.systemPackages`     |
| 模块返回值    | `mkShell` 整体被 `inputsFrom` 引用 | 提取 `buildInputs`, `env`        |
| `shellHook`   | ✅ 生效                            | ❌ 忽略                          |
| `env`         | ✅ 通过 `inputsFrom` 继承          | ✅ 提取到 `environmentVariables` |
| `buildInputs` | ✅ 通过 `inputsFrom` 继承          | ✅ 提取到 `systemPackages`       |
| 作用域        | 当前 shell 会话                    | 全局系统                         |
| 生命周期      | shell 退出后消失                   | 永久安装                         |

---

## 注意事项

### `env` vs `shellHook`

```nix
# ✅ 正确：需要全局的变量放 env
env = {
  NPM_CONFIG_PREFIX = "$HOME/.npm";
  PATH = "$NPM_CONFIG_PREFIX/bin:$PATH";  # 系统环境也能用
};

# ⚠️ 仅交互式 shell 生效的放 shellHook
shellHook = ''
  echo "📦 Node.js environment loaded"
  export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"  # 仅 nix develop 生效
'';
```

- **系统环境**：只读取 `env` 属性
- **`nix develop`**：`inputsFrom` 会继承 `env` + `shellHook`

### 何时需要修复文件？

当组合 shell 的环境变量冲突时，创建 `<shell-name>.nix`：

```nix
# python-cuda.nix
{ pkgs }:

{
  shellHook = ''
    export PYTHONPATH="${pkgs.python3.sitePackages}:$PYTHONPATH"
  '';
}
```

---
