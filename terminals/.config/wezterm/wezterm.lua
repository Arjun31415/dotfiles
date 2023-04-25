local wezterm = require("wezterm")
return {
	window_frame = {
		-- The font used in the tab bar.
		-- Roboto Bold is the default; this font is bundled
		-- with wezterm.
		-- Whatever font is selected here, it will have the
		-- main font setting appended to it to pick up any
		-- fallback fonts you may have used there.
		font = wezterm.font({ family = "Roboto", weight = "Bold" }),

		-- The size of the font in the tab bar.
		-- Default to 10. on Windows but 12.0 on other systems
		font_size = 12.0,

		-- The overall background color of the tab bar when
		-- the window is focused
		active_titlebar_bg = "#333333",

		-- The overall background color of the tab bar when
		-- the window is not focused
		inactive_titlebar_bg = "#333333",
	},
	window_background_opacity = 0.79,
	font_size = 13,
	harfbuzz_features = { "cv12", "ss05", "cv06", "cv30", "ss03", "clig", "liga" },
	-- /home/arjun/.local/share/fonts/ttf/Fisa Code Book Regular.ttf, FontConfig
	font = wezterm.font("Fisa Code", {
		weight = "Regular",
		stretch = "Normal",
		style = "Normal",
	}),
	font_rules = {
		{
			italic = true,
			font = wezterm.font("Fisa Code", { weight = "Light", style = "Italic" }),
		},
	},
	term = "xterm-256color",
	default_cursor_style = "SteadyBar",
	window_padding = {
		left = 2,
		right = 2,
		top = 0,
		bottom = 0,
	},
	color_scheme = "tokyonight",
	automatically_reload_config = true,
	-- colors = require("TabBar"),
	adjust_window_size_when_changing_font_size = false,
	hide_tab_bar_if_only_one_tab = true,
	xcursor_theme = "Catppuccin-Mocha-Maroon-Cursors",
    -- front_end="OpenGL"
}
