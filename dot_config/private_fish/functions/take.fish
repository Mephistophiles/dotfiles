function take --description "mkdir + cd" --wraps mkdir
    set -l all_argv $argv
    argparse -i 'v/verbose' 'p/parents' -- $argv
    mkdir -pv $all_argv && cd $argv
end

