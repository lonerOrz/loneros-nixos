{
  config,
  pkgs,
  ...
}:
{
  programs.neovim.enable = true;

  environment.systemPackages = with pkgs; [
    luarocks # lazy.nvim needed
    tree-sitter # tree-sitter-cli
  ];
}
