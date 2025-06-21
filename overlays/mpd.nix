self: prev: {
  mpd = prev.mpd.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dio_uring=disabled" ];
  });
}
