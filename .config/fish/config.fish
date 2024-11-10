set fish_greeting
eval "$(zoxide init fish --cmd cd)"


alias lgit="lazygit"
alias cls="clear"
alias copy="wl-copy"
alias ls="eza --icons=auto"
alias lt="eza --tree --level=3 --icons=auto"
alias ll="eza -l --icons=auto"
alias llt="eza -l --tree --level=3 --icons=auto"
alias logout="loginctl terminate-session self"
alias cat="bat"
alias rm="safe-rm"
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias restore="$HOME/.local/share/Trash/files" #Trashed files directory
alias back="trash-restore"
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"
alias ......="cd ../../../../../"
alias suspend="systemctl suspend"
alias ff="fzf"
alias py="python"
alias icat="kitten icat"
alias nv="nvim"
alias cp="rsync"
alias sp="nv /tmp/scratchpad.txt"
alias l="ls"

set -Ux EDITOR nvim
set -Ux VISUAL nvim
set -Ux GRAVEYARD ~/.local/share/Trash
set -gx SHELL /usr/bin/fish

fish_add_path /home/user/.cargo/bin
fish_add_path /home/user/.local/bin
fish_add_path /home/user/go/bin

function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t -- $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function bind_dollar
    switch (commandline -t)[-1]
        case "!"
            commandline -f backward-delete-char history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
end

function lk
    set loc (walk $argv); and cd $loc
end

if status is-interactive
    if not set -q ZELLIJ
        zellij -l ~/.config/zellij/layouts/default.kdl
    end
end

function starship_transient_prompt_func
    starship module character
end
starship init fish | source
enable_transience

thefuck --alias | source
