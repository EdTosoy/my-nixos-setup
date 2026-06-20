-- ============================================================
-- COLORSCHEME — GitHub Dark Dimmed
-- Mirrors the qutebrowser GitHub Dark Dimmed × VSCode theme
-- ============================================================
return {
	"projekt0n/github-nvim-theme",
	priority = 1000, -- load before all other plugins
	config = function()
		require("github-theme").setup({
			options = {
				compile_path = vim.fn.stdpath("cache") .. "/github-theme",
				compile_file_suffix = "_compiled",
				hide_end_of_buffer = true,
				hide_nc_statusline = true,
				transparent = false,
				terminal_colors = true,
				dim_inactive = false,
				module_default = true,
				styles = {
					comments = "italic",
					keywords = "italic",
					types = "NONE",
					functions = "NONE",
					variables = "NONE",
					conditionals = "NONE",
					constants = "NONE",
					numbers = "NONE",
					operators = "NONE",
					strings = "NONE",
					identifiers = "NONE",
				},
			},
		})
		vim.cmd.colorscheme("github_dark_dimmed")
	end,
}
