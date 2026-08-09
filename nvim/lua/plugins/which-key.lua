return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		spec = {
			{ "<leader>s", group = "Search",   mode = { "n", "v" } },
			{ "<leader>h", group = "Git hunks", mode = { "n", "v" } },
			{ "<leader>t", group = "Toggle" },
			{ "gr",        group = "LSP" },
		},
	},
}
