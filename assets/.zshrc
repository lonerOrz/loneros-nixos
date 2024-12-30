# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

# Set-up icons for files/folders in terminal
alias ls='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'

# Starting down here, are set in user.nix

#ZSH_THEME="xiong-chiamiov-plus"

#plugins=(
#    git
    #zsh-autosuggestions
    #zsh-syntax-highlighting
#)

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r


# Set-up FZF key bindings (CTRL R for fuzzy history finder)
#source <(fzf --zsh)

#HISTFILE=~/.zsh_history
#HISTSIZE=10000
#SAVEHIST=10000
#setopt appendhistory

# Custom aliases
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias cls='clear'

alias vif='nvim $(fzf -m --perview="~/.config/fzf/fzf-preview.sh {}" --height 30)'
alias fzf='fzf -m --preview="~/.config/fzf/fzf-preview.sh {}" --height 30'
alias pkill='sudo ps sux | fzf | awk '{print \$2}' | xargs kill'
alias shut='shutdown -h now'
alias rmf='rm -rf $(fzf)'

# Env
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
