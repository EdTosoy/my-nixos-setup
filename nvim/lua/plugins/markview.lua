return {
	"OXY2DEV/markview.nvim",
	lazy = false, -- or ft = "markdown" if you want lazy-loading
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons", -- optional, for icons
	},
	opts = {
		preview = {
			enable = true,
			mode = { "n", "no", "c" },
		},
	},
}
