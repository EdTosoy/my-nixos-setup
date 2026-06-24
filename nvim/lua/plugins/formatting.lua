return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
			mode = "",
			desc = "Format buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disable = { c = true, cpp = true }
			if disable[vim.bo[bufnr].filetype] then return nil end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
		formatters_by_ft = {
			lua          = { "stylua" },
			javascript   = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescript   = { "prettierd" },
			typescriptreact = { "prettierd" },
			htmlangular  = { "prettierd" },
			css          = { "prettierd" },
			json         = { "prettierd" },
			jsonc        = { "prettierd" },
			markdown     = { "prettierd" },
			yaml         = { "prettierd" },
			prisma       = { "prettierd" },
		},
	},
}
