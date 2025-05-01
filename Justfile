
configs:
	stow \
		alacritty \
		awesome \
		fish \
		kitty \
		nvim \
		starship \
		wezterm

bins:
	mkdir -p ~/bin
	stow -t ~/bin bin

