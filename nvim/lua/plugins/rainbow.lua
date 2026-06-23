return {
	"HiPhish/rainbow-delimiters.nvim",
	event = "BufReadPost",
	config = function()
		local rainbow = require("rainbow-delimiters")
		vim.g.rainbow_delimiters = {
			strategy = {
				[""] = rainbow.strategy["global"],
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
			},
			highlight = {
				"RainbowDelimiterRed",
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
