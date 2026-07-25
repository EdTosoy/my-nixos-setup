-- ============================================================
-- TREESITTER — main branch
--
-- Neovim 0.12.4 (confirmed via :version) ships the APIs that
-- nvim-treesitter 'main' targets. Previously pinned to 'master'
-- for nixos-25.11/Neovim 0.11 compatibility — no longer needed
-- after the 26.05 "Yarara" upgrade. Staying on master against
-- 0.12 causes injection-query crashes (nil method 'range' in
-- languagetree.lua), especially on markdown.
--
-- main also requires tree-sitter-cli >=0.26.1 — add it to
-- home.nix if :TSUpdate fails to build a parser.
--
-- WHY lazy = false:
--   Without this, treesitter loads on the first BufReadPost.
--   The config function runs right after — but the FileType
--   autocmd for the triggering buffer already fired before
--   config ran, so that buffer never gets highlighting.
--   lazy = false loads at startup so every buffer gets it.
--
-- htmlangular → angular grammar (knows @if/@for, *ngIf,
--   [binding], (event), {{ interpolation }}).
-- ============================================================
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		vim.treesitter.language.register("angular", "htmlangular")
		vim.treesitter.language.register("terraform", "tf")
		vim.treesitter.language.register("hcl", "tfvars")
		require("nvim-treesitter").setup({
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"typescript",
				"javascript",
				"tsx",
				"angular",
				"css",
				"json",
				"jsonc",
				"yaml",
				"nix",
				"prisma",
				"terraform",
				"hcl",
			},
		})
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})
	end,
}
