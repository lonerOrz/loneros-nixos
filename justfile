@install target:
    nix --experimental-features "nix-command flakes" run github:nix-community/disko -- -m disko -f .#{{ target }}
    mkdir -p /mnt/var/lib/sops-nix
    nixos-install --flake .#{{ target }}

@install-remote target ip:
    nix --experimental-features "nix-command flakes" run github:nix-community/nixos-anywhere -- -i ~/.ssh/id_ed25519 --flake .#{{ target }} root@{{ ip }}

@update:
    nix flake update

@update-custom-packages:
    nix-shell -p nix-update nix-prefetch-git jq --run "python .github/script/update.py"

@clean:
    nix-collect-garbage -d

@build target="loneros":
    sudo nixos-rebuild switch --flake .#{{ target }}

@build-remote target ip:
    nixos-rebuild switch --flake .#{{ target }} --target-host "root@{{ ip }}"

@test target="loneros":
    sudo nixos-rebuild test --flake .#{{ target }}

@fix:
    nix-store --repair --verify --check-contents

@geniso:
    nix build .#nixosConfigurations.iso.config.formats.iso

@genfacter:
    nix run github:numtide/nixos-facter -- -o facter.json

@init:
  nix run github:nix-community/nix-init
