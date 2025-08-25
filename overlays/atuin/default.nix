# https://github.com/Mic92/dotfiles/blob/main/home-manager/pkgs/atuin/0001-make-atuin-on-zfs-fast-again.patch
self: super: {
  atuin = super.atuin.overrideAttrs (oldAttrs: rec {
    patches = oldAttrs.patches or [ ] ++ [
      ./atuin-zfs-fast.patch
    ];
  });
}
