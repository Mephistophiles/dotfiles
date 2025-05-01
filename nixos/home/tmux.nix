{ pkgs, ... }:

let
  theme = ./tmux/tokyonight_storm.conf;
in
{
  programs = {
    tmux = {
      enable = true;

      mouse = true;
      keyMode = "vi";
      prefix = "M-w";

      baseIndex = 1;
      historyLimit = 100000;

      reverseSplit = true;
      customPaneNavigationAndResize = true;

      tmuxp.enable = true;

      # focusEvents = true;
      escapeTime = 0;

      terminal = "screen-256color";

      extraConfig = ''
        set -sa terminal-features ",xterm-256color:RGB"
        set -sa terminal-features ",alacritty:RGB"

        set -g allow-passthrough on

        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

        set -g set-titles on
        set -g set-titles-string "#{pane_title}"
        if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
        set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
        set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'

        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' { if -F '#{pane_at_left}' "" 'select-pane -L' }
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' { if -F '#{pane_at_bottom}' "" 'select-pane -D' }
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' { if -F '#{pane_at_top}' ""` 'select-pane -U' }
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' { if -F '#{pane_at_right}' "" 'select-pane -R' }

        bind-key -T copy-mode-vi 'C-h' if -F '#{pane_at_left}' "" 'select-pane -L'
        bind-key -T copy-mode-vi 'C-j' if -F '#{pane_at_bottom}' "" 'select-pane -D'
        bind-key -T copy-mode-vi 'C-k' if -F '#{pane_at_top}' "" 'select-pane -U'
        bind-key -T copy-mode-vi 'C-l' if -F '#{pane_at_right}' "" 'select-pane -R'

        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-selection
        bind -T copy-mode-vi Y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

        source-file ${theme}
      '';

    };
  };
}
