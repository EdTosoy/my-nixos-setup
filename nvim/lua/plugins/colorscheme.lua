return {
	"projekt0n/github-nvim-theme",
	priority = 1000,
	config = function()
		require("github-theme").setup({
			options = {
				compile_path = vim.fn.stdpath("cache") .. "/github-theme",
				compile_file_suffix = "_compiled",
				hide_end_of_buffer = true,
				transparent = false,
				terminal_colors = true,
				dim_inactive = false,
				styles = {
					comments = "italic",
					keywords = "italic",
					functions = "NONE",
					variables = "NONE",
				},
			},
		})
		vim.cmd.colorscheme("github_dark_dimmed")
		vim.api.nvim_set_hl(0, "Visual", { bg = "#444c56", fg = "NONE" })
		vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "NONE" })
	end,
}
