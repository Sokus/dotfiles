bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey '\e[5~' beginning-of-history
bindkey '\e[6~' end-of-history
#bindkey '\e[7~' beginning-of-line
bindkey '\e[3~' delete-char
bindkey '\e[2~' quoted-insert
#bindkey '\e[5C' forward-word
#bindkey '\e[5D' backward-word
#bindkey '\e\e[C' forward-word
#bindkey '\e\e[D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '\e[1;5D' backward-word
bindkey '\e[1;3C' forward-word
bindkey '\e[1;3D' backward-word
bindkey '\e[3;3~' delete-word

# Added by Sokus
alias tree="tree -C"
alias ls="ls --color=auto --group-directories-first"
alias clipboard="xclip -selection c"
alias bat="bat -p"

function 4coder() { (nohup /usr/sokus-bin/4coder/4ed "$@" &) 1>/dev/null 2>&1 }
function gf() { (nohup /usr/sokus-bin/gf/gf2 "$@" &) 1>/dev/null 2>&1 }

PS1_NM="%(!.%F{red}.%F{green})%n@%m%f"
PS1_W="%F{cyan}%~%f"
PS1="$PS1_NM $PS1_W "

# The following lines were added by compinstall

zstyle ':completion:*' chhhompleter _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/sokus/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

if [ -d $HOME/Git/themes/zsh ]; then
	source $HOME/Git/themes/zsh/dracula.zsh-theme
fi
