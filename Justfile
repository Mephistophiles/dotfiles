
configs:
	stow \
		alacritty \
		awesome \
		fish \
		kitty \
		lazygit \
		nvim \
		rofi \
		starship \
		tmux \
		wezterm

bins:
	stow -t ~/bin bin

nixos:
	sudo stow -t /etc nixos
