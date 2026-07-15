return {
	"brenoprata10/nvim-highlight-colors",
	opts = {
		render = "virtual", -- Renders as virtual text
		virtual_symbol = "■", -- The symbol used (e.g., a colored square)
		virtual_symbol_position = "inline", -- Places it inline with the text
		virtual_symbol_suffix = "", -- Removes trailing space
		enable_hex = true,
		enable_short_hex = true,
		enable_rgb = true,
		enable_hsl = true,
		enable_named_colors = true,
	},
}
