set -gx EDITOR nvim

fnm env --use-on-cd --shell fish | source

function lol -a name
    nvim $HOME/Documents/scratch/$name.md
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function cwd
    pwd | pbcopy
    echo "Copied $(pwd)"
end

function fish_greeting
    printf "\n"
    printf '     ✦    __        ⋆\n'
    printf '%s%s' (set_color -o yellow) '        <' (set_color -o black) '(o )___    ✧'
    printf '\n   ✧    ( ._> /       ✦\n'
    printf "      ⋆  `---'    ✧\n"
    printf "\n"
end

alias k="kubectl"

if status is-interactive
    atuin init fish | source
end

# plugins
zoxide init fish | source
