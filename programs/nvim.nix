{
  config,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;
  };
  environment.systemPackages = with pkgs; [
    luarocks # lazy.nvim needed
    tree-sitter # tree-sitter-cli
  ];
}
