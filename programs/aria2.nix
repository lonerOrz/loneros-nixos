{
  username,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    aria2
  ];

  systemd.services.aria2 = {
    description = "Aria2 Download Manager";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = username;
      ExecStart = ''
        ${pkgs.aria2}/bin/aria2c \
                --enable-rpc \
                --rpc-listen-all=true \
                --rpc-listen-port=6800 \
                # --rpc-secret=123456 \
                --dir=/home/${username}/Downloads/aria2 \
                --file-allocation=trunc
      '';
      Restart = "always";
      RestartSec = 5;
      StartLimitIntervalSec = 60;
      StartLimitBurst = 5;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
