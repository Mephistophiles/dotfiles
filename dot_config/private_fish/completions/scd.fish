function _scd_need_replacement_path
    set numargs (count $argv)

    switch $numargs
        case "1"
          return 1
        case "2"
          return 0
    end

    return 1
end
complete -c scd -w cd


