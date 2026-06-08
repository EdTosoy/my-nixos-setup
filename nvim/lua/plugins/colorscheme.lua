-- ============================================================
-- COLORSCHEME — One Dark Pro Night Flat
-- bg overridden to #1e1e1e to match Night Flat exactly
-- ============================================================
return {
	"olimorris/onedarkpro.nvim",
	priority = 1000, -- load before all other plugins
	config = function()
		require("onedarkpro").setup({
			colors = {
				bg = "#1e1e1e",
				bg_float = "#1e1e1e",
			},
			styles = {
				comments = "italic",
				keywords = "italic",
				functions = "NONE",
				variables = "NONE",
			},
			options = {
				bold = true,
				italic = true,
			},
		})
		vim.cmd.colorscheme("onedark_dark")
	end,
}
