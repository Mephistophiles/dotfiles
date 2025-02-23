
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
	mkdir -p ~/bin
	stow -t ~/bin bin

