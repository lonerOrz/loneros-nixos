{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs.nur.repos.lonerOrz; [
    wechat-sandbox
  ];
}
