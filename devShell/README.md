# DevShell

Modular development environment powered by a **Single Source of Truth (SSOT)** design for both ephemeral shells and global system profiles.

```

                         ┌─────────────────────────────────┐
                         │   devShell/*.nix (Module Spec)  │
                         │   - nativeBuildInputs (tools)   │
                         │   - buildInputs (libraries)     │
                         │   - env (variables)             │
                         │   - shellHook (scripts)         │
                         └────────────────┬────────────────┘
                                          │
                 ┌────────────────────────┴────────────────────────┐
                 ▼                                                 ▼
      [Workflow 1: Interactive]                         [Workflow 2: System Profile]
      devShell/default.nix                              devShell/package.nix
      ├─ inputsFrom = [ modules... ]                    ├─ systemPackages = tools + libs
      └─ outputs: pkgs.mkShell                          └─ environmentVariables = env
                 │                                                 │
                 ▼                                                 ▼
      nix develop / direnv (.envrc)                     hosts/loneros/dev.nix

```

---

## 🚀 Quick Start

### 1. Interactive Shell (`nix develop`)

```bash
nix develop .#c            # C/C++ toolchain & core libraries
nix develop .#dev          # Full-stack developer bundle
nix develop .#python-cuda  # Composite environment (Python + CUDA)
```

### 2. Auto-load via Direnv (`.envrc`)

Add to any project's `.envrc` and run `direnv allow`:

```bash
# Recommended: Local repo (Instant evaluation & live reload on edit) ⭐
use flake ~/loneros-nixos#rust

# Universal: Remote GitHub flake (Works on any machine with Nix)
use flake github:lonerOrz/loneros-nixos#dev
```

### 3. System-level Installation (`hosts/loneros/dev.nix`)

```nix
packagesForSystem = import ../../devShell/package.nix {
  inherit pkgs lib;
  modulesList = [ "node" "python" "c" "rust" "lua" "go" ];
};

environment.systemPackages = packagesForSystem.systemPackages;
environment.variables = packagesForSystem.environmentVariables;
```

---

## 📊 Workflow Comparison

| Feature                 | Workflow 1: `nix develop` / `direnv`    | Workflow 2: System Profile       |
| :---------------------- | :-------------------------------------- | :------------------------------- |
| **Consumer**            | `devShell/default.nix`                  | `devShell/package.nix`           |
| **Destination**         | Temporary subshell session              | NixOS `/run/current-system`      |
| **`nativeBuildInputs`** | ✅ Host build tools in `$PATH`          | ✅ Global system binaries        |
| **`buildInputs`**       | ✅ Compiler headers & `PKG_CONFIG_PATH` | ✅ Global system libraries       |
| **`env`**               | ✅ Session environment variables        | ✅ Global `/etc/profile.d`       |
| **`shellHook`**         | ✅ Executed on shell entry              | ❌ Ignored (prevents noise)      |
| **Lifecycle**           | Transient (disappears upon exit)        | Persistent across system reboots |

---

## 🛠️ Module Development Rules

### 1. Standard Module Contract (`devShell/<lang>.nix`)

Every module returns `pkgs.mkShell`:

```nix
{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ gcc cmake pkg-config ]; # Build tools
  buildInputs = with pkgs; [ zlib openssl ];               # Libraries
  env = { CPATH = "${pkgs.zlib.dev}/include"; };           # Shared variables
  shellHook = ''echo "🛠️ C environment loaded"'';          # Shell-only scripts
}
```

### 2. `env` vs `shellHook`

- **Use `env`** for static paths and compiler flags (`RUST_SRC_PATH`, `NPM_CONFIG_PREFIX`, `DOTNET_ROOT`).
- **Use `shellHook`** for interactive messages and PATH mutations (`export PATH=...`).

### 3. Composite Shell Overrides

Composite shells combine existing modules without duplicating packages. Create `<name>.nix` only when extra glue is required:

```nix
# devShell/python-cuda.nix (Overrides & glue only)
{ pkgs, ... }:

{
  shellHook = ''
    export PYTHONPATH="${pkgs.python3.sitePackages}:$PYTHONPATH"
    echo "🐍🚀 Python + CUDA DevShell ready"
  '';
}
```
