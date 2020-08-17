fish_default_key_bindings

export EDITOR=nvim

alias vim='nvim'
abbr -a vimdiff 'nvim -d'

abbr --add ls "exa"
abbr --add ll "exa -l"

abbr --add cat "bat"

abbr --add lg "lazygit"

abbr -a sc-enable sudo systemctl enable
abbr -a sc-disable sudo systemctl disable
abbr -a sc-start sudo systemctl start
abbr -a sc-restart sudo systemctl restart
abbr -a sc-stop sudo systemctl stop
abbr -a sc-status sudo systemctl status

abbr -a scu-enable systemctl --user enable
abbr -a scu-disable systemctl --user disable
abbr -a scu-start systemctl --user start
abbr -a scu-restart systemctl --user restart
abbr -a scu-stop systemctl --user stop
abbr -a scu-status systemctl --user status

set -U fish_user_paths $fish_user_paths $HOME/bin
set -U fish_user_paths $fish_user_paths $HOME/builder_bin
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin/
set -U fish_user_paths $fish_user_paths $HOME/go/bin/

set -U fish_user_paths (printf '%s\n' $fish_user_paths | sort -u)

if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

starship init fish | source
zoxide init fish | source
