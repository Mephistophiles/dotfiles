local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.color_scheme = "Tokyo Night Storm"
config.hide_tab_bar_if_only_one_tab = true

return config
