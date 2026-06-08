-- ============================================================
-- GIT
-- ============================================================
return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local map = function(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end
			map("n", "]h", gs.next_hunk, "Next git [H]unk")
			map("n", "[h", gs.prev_hunk, "Prev git [H]unk")
			map("n", "<leader>hs", gs.stage_hunk, "[H]unk [S]tage")
			map("n", "<leader>hr", gs.reset_hunk, "[H]unk [R]eset")
			map("n", "<leader>hp", gs.preview_hunk, "[H]unk [P]review")
			map("n", "<leader>hb", gs.blame_line, "[H]unk [B]lame line")
			map("n", "<leader>hd", gs.diffthis, "[H]unk [D]iff")
		end,
	},
}
