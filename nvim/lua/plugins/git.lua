return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add          = { text = "+" },
			change       = { text = "~" },
			delete       = { text = "_" },
			topdelete    = { text = "‾" },
			changedelete = { text = "~" },
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local map = function(l, r, desc)
				vim.keymap.set("n", l, r, { buffer = bufnr, desc = desc })
			end
			map("]h", gs.next_hunk,    "Next hunk")
			map("[h", gs.prev_hunk,    "Prev hunk")
			map("<leader>hs", gs.stage_hunk,   "Stage hunk")
			map("<leader>hr", gs.reset_hunk,   "Reset hunk")
			map("<leader>hp", gs.preview_hunk, "Preview hunk")
			map("<leader>hb", gs.blame_line,   "Blame line")
			map("<leader>hd", gs.diffthis,     "Diff this")
		end,
	},
}
