function tmux-renew-env --description "Update env under tmux"
    for line in (tmux show-env)
        if string match -rq '^-' -- "$line"
            set -l var (string sub -s 2 -- "$line")
            set -eg "$var"
        else
            set -l pair (string split -m 1 = -- "$line")
            if test (count $pair) -eq 2
                set -gx "$pair[1]" "$pair[2]"
            end
        end
    end
end
