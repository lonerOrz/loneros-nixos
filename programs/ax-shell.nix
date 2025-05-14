{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
let
  nur = inputs.nur.legacyPackages."${system}";
in
{
  environment.systemPackages = with pkgs; [
    aria2
    nur.repos.HeyImKyu.fabric-cli
    (nur.repos.HeyImKyu.run-widget.override {
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
        nur.repos.HeyImKyu.fabric-gray
        networkmanager
        networkmanager.dev
        playerctl
      ];
    })
  ];

}
