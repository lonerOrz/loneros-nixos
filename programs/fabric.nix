{
  inputs,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nur.repos.lonerOrz.fabric-cli
    (nur.repos.lonerOrz.run-fabric.override {
      extraPythonPackages = with python3Packages; [
        ijson
        pillow
        psutil
        requests
        setproctitle
        toml
        watchdog
        thefuzz
        numpy
        chardet

        pyjson5
        pytomlpp
      ];
      extraBuildInputs = [
        nur.repos.lonerOrz.fabric-gray
        nur.repos.lonerOrz.fabric-glace
        networkmanager
        networkmanager.dev
        playerctl
      ];
    })
  ];
}
