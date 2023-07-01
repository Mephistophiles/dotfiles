function matebook --description "switch matebook battery modes"
    set -l mode
    switch "$argv"
        case "home"
            set mode "40 70"
        case "office"
            set mode "70 90"
        case "travel"
            set mode "95 100"
        case "off"
            set mode "0 100"
    end

    echo $mode | sudo tee /sys/bus/platform/devices/huawei-wmi/charge_control_thresholds
end

complete -c matebook -a "home office travel off" -f
