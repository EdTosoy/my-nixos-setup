return {
	"HiPhish/rainbow-delimiters.nvim",
	lazy = false,
	config = function()
		local rainbow = require("rainbow-delimiters")
		vim.g.rainbow_delimiters = {
			strategy = {
				[""] = rainbow.strategy["global"],
				typescript = rainbow.strategy["local"],
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
				typescript = "rainbow-delimiters",
				javascript = "rainbow-delimiters",
				tsx = "rainbow-delimiters",
			},
			highlight = {
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
				"RainbowDelimiterCyan",
			},
		}
	end,
}
