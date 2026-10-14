# fzf key bindings (ctrl+t) and fuzzy completion (**<Tab>), from the installed fzf.
# Empty commands turn off its ctrl+r (atuin owns it) and alt+c.
export FZF_CTRL_T_COMMAND="fd --type file --strip-cwd-prefix --hidden --follow --exclude .git"
export FZF_CTRL_R_COMMAND=""
export FZF_ALT_C_COMMAND=""
source <(fzf --zsh)

export FZF_DEFAULT_OPTS="\
    --color=fg:#f8f8f2,hl:#bd93f9 \
    --color=fg+:#f8f8f2,hl+:#bd93f9 \
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 \
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 \
    --bind 'ctrl-a:toggle-all' \
    --bind 'ctrl-n:preview-half-page-down' \
    --bind 'ctrl-p:preview-half-page-up' \
    --prompt='░ ' \
    --marker='•' \
    --pointer='▓'
"
export FZF_TMUX_OPTS="-p"
