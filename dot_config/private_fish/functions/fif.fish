function fif
    if ! count $argv >/dev/null
        echo "Need a string to search for!"
        return 1
    end

    set -l str $argv[1]

    rg --files-with-matches --no-messages "$str" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --ignore-case --pretty --context 10 '$str' || rg --ignore-case --pretty --context 10 '$str' {}"
end

