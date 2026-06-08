-- ============================================================
-- TODO COMMENTS
-- ============================================================
return {
	"folke/todo-comments.nvim",
	event = "VimEnter",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		signs = false,
		keywords = {
			NOTE = { icon = "󰋽 ", color = "hint" },
		},
	},
}
