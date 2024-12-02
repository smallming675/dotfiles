set fish_greeting
eval "$(zoxide init fish)"

alias lgit="lazygit"
alias cls="clear"
alias copy="wl-copy"
alias ls="eza --icons=auto"
alias la="eza --icons=auto"
alias lt="eza --tree --level=3 --icons=auto"
alias ll="eza -l --icons=auto"
alias llt="eza -l --tree --level=3 --icons=auto"
alias logout="loginctl terminate-session self"
alias cat="bat"
alias rm="rip"
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
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias py="python"
alias nv="nvim"
alias cp="rsync"
alias ghc="gh copilot"
alias l="ls"

set -x EDITOR nvim
set -x VISUAL nvim
set -x GRAVEYARD ~/.local/share/Trash
set -x SHELL /usr/bin/fish
set -x RUSTC_WRAPPER sccache
set -x MANPAGER "nvim +Man!"

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

function fish_user_key_bindings
    bind ! bind_bang
end

if status is-interactive
    if not set -q ZELLIJ
        zellij -l ~/.config/zellij/layouts/default.kdl attach --index 0 -c
    end
end

function starship_transient_prompt_func
    starship module character
end

starship init fish | source
enable_transience
mise activate fish | source
