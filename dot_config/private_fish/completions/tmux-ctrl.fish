function __fish_tmux_sessions -d 'available sessions'
    tmux list-sessions -F "#S	#{session_windows} windows created: #{session_created_string} [#{session_width}x#{session_height}]#{session_attached}" | sed 's/0$//;s/1$/ (attached)/' 2>/dev/null
end

complete -f -c tmux-switch -a "(__fish_tmux_sessions)"
complete -f -c tmux-attach -a "(__fish_tmux_sessions)"
complete -f -c tmux-create -a "(__fish_tmux_sessions)"
complete -f -c tmux-kill -a "(__fish_tmux_sessions)"
