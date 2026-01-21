<h1 align="center">
   <img src="assets/preview/nixos-logo.png" alt="NixOS Logo" width="100px" />
   <br>
   Lonero's NixOS Configuration
   <br>
      <a href="https://github.com/catppuccin/catppuccin">
        <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px" />
      </a>
   <br>
</h1>

<p align="center">
    My personal NixOS configuration, managed with Nix Flakes.
</p>

<div align="center">
    <a href="https://github.com/lonerOrz/loneros-nixos/stargazers">
        <img src="https://img.shields.io/github/stars/lonerOrz/loneros-nixos?color=F5BDE6&labelColor=303446&style=for-the-badge&logo=starship&logoColor=F5BDE6" alt="GitHub Stars">
    </a>
    <a href="https://github.com/lonerOrz/loneros-nixos/">
        <img src="https://img.shields.io/github/repo-size/lonerOrz/loneros-nixos?color=C6A0F6&labelColor=303446&style=for-the-badge&logo=github&logoColor=C6A0F6" alt="Repo Size">
    </a>
    <a href="https://nixos.org">
        <img src="https://img.shields.io/badge/NixOS-Unstable-blue?style=for-the-badge&logo=NixOS&logoColor=white&label=NixOS&labelColor=303446&color=91D7E3" alt="NixOS Unstable">
    </a>
    <a href="https://github.com/lonerOrz/loneros-nixos/blob/main/LICENSE">
        <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&colorA=313244&colorB=F5A97F&logo=unlicense&logoColor=F5A97F&" alt="License MIT">
    </a>
</div>

## 🖼️ Previews

### 🌟 Catppuccin Style

| ![Preview 1](assets/preview/catppuccin.png) |
| :-----------------------------------------: |

<details>
  <summary>🎨 Gruvbox Style (Click to expand)</summary>

| ![Preview 1](assets/preview/gruvbox.png) |
| :--------------------------------------: |

</details>

<details>
  <summary>🎨 Nord Style (Click to expand)</summary>

| ![Preview 1](assets/preview/Nord.png) |
| :-----------------------------------: |

</details>

---

> [!IMPORTANT]
> Note: Although this configuration includes home-manager integration, I do not use it for managing user configurations.

> [!CAUTION]
> This configuration contains encrypted secrets managed by sops-nix that require my personal keys. Do not attempt to directly install this configuration.

---

## ✨ Features

- **Declarative & Reproducible**: Managed entirely by Nix Flakes
- **Desktop Environment**: Hyprland/Niri with Stylix theming
- **Security**: Encrypted secrets with sops-nix
- **Development**: Neovim with nvf configuration

---

## 📂 Structure

This repository is organized as follows:

- `flake.nix`: The entry point for the entire configuration, defining all inputs and outputs.
- `hosts/`: Contains system-level configurations for specific machines.
  - `loneros/`: Main desktop system with NVIDIA GPU support, Hyprland/Niri window managers, and comprehensive application suite.
  - `loneros-wsl/`: WSL-specific configuration for Windows Subsystem for Linux with optimized packages for development.
  - `bootstrap/`: Minimal installation environment with impermanence support, used for system installation and recovery.
  - `remote-vm/`: Remote virtual machine configuration with secure boot support.
- `home/`: Manages user-level application configurations and dotfiles.
- `system/`: Holds global, cross-host system modules.
- `programs/`: Declaratively manages configurations for various applications.
- `servers/`: Contains configurations for system background services.
- `modules/`: Reusable custom NixOS modules for different configurations.
- `overlays/`: Modifications or overrides for existing packages in `nixpkgs`.
- `pkgs/`: Contains custom-defined packages.
- `themes/`: Manages themes and visual styles for the system and applications.
- `devShell/`: Provides development environments for different programming languages.
- `iso/`: Configuration for building a bootable NixOS ISO image.
- `deploy/`: Contains configurations related to remote deployment.
- `cluster/`: Kubernetes cluster configurations (k3s, kubeconfig).
- `lib/`: Contains custom Nix helper functions.
- `secrets/`: Manages encrypted files using `sops-nix`.

---

## ☁️ Cache

- substituter: `https://loneros.cachix.org`
- public-key: `loneros.cachix.org-1:dVCECfW25sOY3PBHGBUwmQYrhRRK2+p37fVtycnedDU=`
