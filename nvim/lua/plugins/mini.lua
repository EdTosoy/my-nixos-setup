return {
	"echasnovski/mini.nvim",
	config = function()
		require("mini.ai").setup({ n_lines = 500 })
		require("mini.surround").setup()
		require("mini.pairs").setup()

		require("mini.move").setup({
			mappings = {
				left = "<M-h>", right = "<M-l>", down = "<M-j>", up = "<M-k>",
				line_left = "<M-h>", line_right = "<M-l>", line_down = "<M-j>", line_up = "<M-k>",
			},
		})

		-- gS → split one-liner to multi-line | gJ → join back
		require("mini.splitjoin").setup()

		-- Extended bracket navigation: ]b/[b ]t/[t etc.
		require("mini.bracketed").setup()

		-- File explorer
		require("mini.files").setup({
			windows = { preview = true, width_preview = 50 },
			options = { use_as_default_explorer = true },
		})
		vim.keymap.set("n", "<leader>.", function()
			local mf = require("mini.files")
			if not mf.close() then mf.open(vim.api.nvim_buf_get_name(0)) end
		end, { desc = "File explorer (current file)" })
		vim.keymap.set("n", "<leader>E", function()
			local mf = require("mini.files")
			if not mf.close() then mf.open() end
		end, { desc = "File explorer (cwd)" })

		-- Statusline
		require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })

		-- Mode colors — GitHub Dark Dimmed palette (matches qutebrowser theme)
		local function set_mode_hl()
			vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal",  { bg = "#2d333b", fg = "#cdd9e5", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert",  { bg = "#1f3325", fg = "#cdd9e5", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual",  { bg = "#264466", fg = "#cdd9e5", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { bg = "#351515", fg = "#cdd9e5", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { bg = "#1c2128", fg = "#cdd9e5", bold = true })
		end
		set_mode_hl()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_mode_hl })

		local mode_map = {
			["n"]  = { label = "NORMAL",  hl = "MiniStatuslineModeNormal" },
			["i"]  = { label = "INSERT",  hl = "MiniStatuslineModeInsert" },
			["v"]  = { label = "VISUAL",  hl = "MiniStatuslineModeVisual" },
			["V"]  = { label = "V-LINE",  hl = "MiniStatuslineModeVisual" },
			["\22"]= { label = "V-BLOCK", hl = "MiniStatuslineModeVisual" },
			["R"]  = { label = "REPLACE", hl = "MiniStatuslineModeReplace" },
			["c"]  = { label = "COMMAND", hl = "MiniStatuslineModeCommand" },
			["t"]  = { label = "TERMINAL",hl = "MiniStatuslineModeInsert" },
		}

		MiniStatusline.config.content.active = function()
			local m = mode_map[vim.fn.mode()] or { label = vim.fn.mode(), hl = "MiniStatuslineModeNormal" }
			local git  = MiniStatusline.section_git({ trunc_width = 75 })
			local diag = MiniStatusline.section_diagnostics({ trunc_width = 75 })
			local file = MiniStatusline.section_filename({ trunc_width = 140 })
			return MiniStatusline.combine_groups({
				{ hl = m.hl,                        strings = { m.label } },
				{ hl = "MiniStatuslineDevinfo",     strings = { git } },
				"%<",
				{ hl = "MiniStatuslineFilename",    strings = { file } },
				"%=",
				{ hl = "MiniStatuslineDevinfo",     strings = { diag } },
				{ hl = m.hl,                        strings = { "%2l:%-2v" } },
			})
		end
	end,
}
