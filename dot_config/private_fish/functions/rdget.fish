function rdget
    git clone git@rd:$argv[1]
end

function __rdget
    set -l cache_file "/tmp/.rdget.cache"

    set -l cache_invalidated (find "$cache_file" -mmin 120 2>/dev/null)

    if test -f "$cache_file" -a -z "$cache_invalidated"
        cat $cache_file
    else
        ssh git@rd 2>/dev/null | \
            tail -n +3 | \
            sed -E 's/\s+R\s+(W)?\s+//' | \
            dos2unix | \
            tee $cache_file
    end
end

complete -f -c rdget -a '(__rdget)'

