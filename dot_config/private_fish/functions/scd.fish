function scd
    set numargs (count $argv)
    switch $numargs
        case "1"
            cd $argv
        case "2"
            cd (echo (pwd) | sed "s/$argv[1]/$argv[2]/g")
   end
end
