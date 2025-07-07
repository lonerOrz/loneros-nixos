{
  pkgs,
  config,
  username,
  ...
}:
{
  system.userActivationScripts.dot = {
    # 可以加依赖，如果需要，比如 network-online.target
    # deps = ["network-online.target"];

    text = ''
      export PATH=${pkgs.git}/bin:$PATH

      DOTFILES_DIR="$HOME/dotfiles"
      REPO_URL="https://github.com/lonerOrz/dotfiles.git"

      # 获取最新的 dotfiles
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo "Cloning dotfiles repo to $DOTFILES_DIR..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
      else
        echo "Dotfiles already present, pulling latest changes..."
        cd "$DOTFILES_DIR"
        git pull --rebase --autostash
      fi
    '';
  };
}
