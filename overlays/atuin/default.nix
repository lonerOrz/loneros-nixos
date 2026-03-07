# https://github.com/Mic92/dotfiles/blob/main/home-manager/pkgs/atuin/0001-make-atuin-on-zfs-fast-again.patch
self: super: {
  atuin = super.atuin.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches or [ ] ++ [
      ./atuin-zfs-fast.patch
    ];

    cargoTestFlags = (oldAttrs.cargoTestFlags or [ ]) ++ [
      "--"
      "--skip"
      "dumb_random_test"
    ];
  });
}
