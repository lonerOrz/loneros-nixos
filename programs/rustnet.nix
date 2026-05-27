{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    rustnet
  ];

  security.wrappers.rustnet = {
    source = "${pkgs.rustnet}/bin/rustnet";
    owner = "root";
    group = "root";
    capabilities = "cap_net_raw,cap_bpf,cap_perfmon+eip";
  };
}
