{ pkgs, ... }:

{
  programs = {
    tmux = {
      aggressiveResize = true;
      enable = true;
      clock24 = true;
      escapeTime = 0;
      baseIndex = 1;
      historyLimit = 50000;
      terminal = "screen-256color";
      extraConfig = ''
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides ",alacritty:RGB"
        set -ga terminal-overrides ",alacritty:Tc"
        set -g update-environment " SSH_CONNECTION SSH_CLIENT SSH_TTY DISPLAY XAUTHORITY SSH_AUTH_SOCK XDG_SESSION_CLASS XDG_SESSION_TYPE DBUS_SESSION_BUS_ADDRESS XDG_SESSION_ID XDG_RUNTIME_DIR"
        set -g allow-rename off
        set -g mouse on

        bind-key : command-prompt
        bind-key r refresh-client
        bind-key L clear-history

        bind-key space next-window
        bind-key bspace previous-window
        bind-key enter next-layout

        # use vim-like keys for splits and windows
        bind-key v split-window -h -c "#{pane_current_path}"
        bind-key s split-window -v -c "#{pane_current_path}"
        bind-key B break-pane
        bind-key J command-prompt -p "join pane from:"  "join-pane -s '%%'"
        bind-key S command-prompt -p "send pane to:"  "join-pane -t '%%'"
        bind-key -r N swap-window -t:+
        bind-key -r P swap-window -t:-
        bind-key r rotate-window

        bind-key K swap-pane -U
        bind-key J swap-pane -D
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R

        # Use Alt-vim keys without prefix key to switch panes
        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R

        bind -n S-Left previous-window
        bind -n S-Right next-window

        bind-key + select-layout main-horizontal
        bind-key = select-layout main-vertical
        set-window-option -g other-pane-height 25
        set-window-option -g other-pane-width 80

        bind-key a last-pane
        bind-key q display-panes
        bind-key c new-window
        bind-key t next-window
        bind-key T previous-window

        bind-key [ copy-mode
        bind-key ] paste-buffer

        # Setup 'v' to begin selection as in Vim
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection
        bind-key -T copy-mode-vi 'Space' send -X halfpage-down
        bind-key -T copy-mode-vi 'Bspace' send -X halfpage-up

        # Update default binding of `Enter` to also use copy-pipe
        unbind-key -T copy-mode-vi 'Enter'
        #unbind -t vi-copy Enter
        #bind-key -t vi-copy Enter copy-pipe "reattach-to-user-namespace pbcopy"
        bind-key -T copy-mode-vi 'Enter' send -X copy-pipe

        set-window-option -g display-panes-time 1500

        # Allow the arrow key to be used immediately after changing windows
        set-option -g repeat-time 0

        # Fix to allow mousewheel/trackpad scrolling in tmux 2.1
        bind-key -T root WheelUpPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
        bind-key -T root WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"

        # Disable assume-paste-time, so that iTerm2's "Send Hex Codes" feature works
        # with tmux 2.1. This is backwards-compatible with earlier versions of tmux,
        # AFAICT.
        set-option -g assume-paste-time 0

        # Set window notifications
        setw -g monitor-activity off

        set -g default-terminal "screen-256color"

      '';
      keyMode = "vi";
      prefix = "M-w";
      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.resurrect
        tmuxPlugins.power-theme
        tmuxPlugins.tilish
      ];
    };
  };
}
