
configs:
	stow \
		alacritty \
		awesome \
		fish \
		kitty \
		nvim \
		rofi \
		starship \
		wezterm

bins:
	mkdir -p ~/bin
	stow -t ~/bin bin

