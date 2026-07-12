-- ============================================================
-- TREESITTER — legacy master branch
--
-- WHY master not main:
--   nvim-treesitter 'main' requires Neovim >=0.12 and
--   tree-sitter-cli >=0.26.1. nixos-25.11 ships neither.
--   'master' only needs gcc (already in home.nix) and works
--   on Neovim 0.11.
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
	branch = "master",
	build = ":TSUpdate",
	config = function()
		-- Must be called before setup so htmlangular buffers
		-- get the angular parser instead of falling back to html
		vim.treesitter.language.register("angular", "htmlangular")
		vim.treesitter.language.register("terraform", "tf")
		vim.treesitter.language.register("hcl", "tfvars")

		require("nvim-treesitter.configs").setup({
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
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
