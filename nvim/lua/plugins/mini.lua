-- ============================================================
-- MINI.NVIM
-- ============================================================
return {
	"echasnovski/mini.nvim",
	config = function()
		-- Text objects: va), vi", etc.
		require("mini.ai").setup({ n_lines = 500 })

		-- Surround: sa/sd/sr
		require("mini.surround").setup()

		-- Auto-pairs
		require("mini.pairs").setup()

		-- Move lines/selections with Alt+hjkl (replaces VSCode alt+arrow)
		require("mini.move").setup({
			mappings = {
				left = "<M-h>",
				right = "<M-l>",
				down = "<M-j>",
				up = "<M-k>",
				line_left = "<M-h>",
				line_right = "<M-l>",
				line_down = "<M-j>",
				line_up = "<M-k>",
			},
		})

		-- gS splits one-liner → multi-line, gJ joins back
		-- Great for Angular decorators: @Component({...}) →gS→ expanded
		require("mini.splitjoin").setup()

		-- Extended bracket navigation: ]b/[b ]t/[t ]c/[c
		require("mini.bracketed").setup()

		-- File explorer
		require("mini.files").setup({
			windows = { preview = true, width_preview = 50 },
			options = { use_as_default_explorer = true },
		})
		vim.keymap.set("n", "<leader>.", function()
			local mf = require("mini.files")
			if not mf.close() then
				mf.open(vim.api.nvim_buf_get_name(0))
			end
		end, { desc = "File explorer (current file)" })
		vim.keymap.set("n", "<leader>e", function()
			local mf = require("mini.files")
			if not mf.close() then
				mf.open()
			end
		end, { desc = "File explorer (cwd)" })

		-- Statusline with mode colors matching VSCode nvim-ui-modes
		local statusline = require("mini.statusline")
		statusline.setup({ use_icons = vim.g.have_nerd_font })

		local function set_mode_highlights()
			vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { bg = "#3C3C3C", fg = "#CCCCCC", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { bg = "#4B6E6E", fg = "#CCCCCC", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { bg = "#094771", fg = "#CCCCCC", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { bg = "#6E4B4B", fg = "#CCCCCC", bold = true })
			vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { bg = "#2D2D2D", fg = "#CCCCCC", bold = true })
		end
		set_mode_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_mode_highlights })

		local mode_map = {
			["n"] = { label = "NORMAL", hl = "MiniStatuslineModeNormal" },
			["i"] = { label = "INSERT", hl = "MiniStatuslineModeInsert" },
			["v"] = { label = "VISUAL", hl = "MiniStatuslineModeVisual" },
			["V"] = { label = "V-LINE", hl = "MiniStatuslineModeVisual" },
			["\22"] = { label = "V-BLOCK", hl = "MiniStatuslineModeVisual" },
			["R"] = { label = "REPLACE", hl = "MiniStatuslineModeReplace" },
			["c"] = { label = "COMMAND", hl = "MiniStatuslineModeCommand" },
			["t"] = { label = "TERMINAL", hl = "MiniStatuslineModeInsert" },
		}

		MiniStatusline.config.content.active = function()
			local m = mode_map[vim.fn.mode()] or { label = vim.fn.mode(), hl = "MiniStatuslineModeNormal" }
			local git = MiniStatusline.section_git({ trunc_width = 75 })
			local diag = MiniStatusline.section_diagnostics({ trunc_width = 75 })
			local file = MiniStatusline.section_filename({ trunc_width = 140 })
			local loc = "%2l:%-2v"
			return MiniStatusline.combine_groups({
				{ hl = m.hl, strings = { m.label } },
				{ hl = "MiniStatuslineDevinfo", strings = { git } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { file } },
				"%=",
				{ hl = "MiniStatuslineDevinfo", strings = { diag } },
				{ hl = m.hl, strings = { loc } },
			})
		end
	end,
}
