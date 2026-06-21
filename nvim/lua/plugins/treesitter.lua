-- ============================================================
-- TREESITTER (legacy/master API)
--
-- IMPORTANT: 'main' is now nvim-treesitter's DEFAULT branch (the
-- new rewrite). 'master' (the classic API used below) must be
-- pinned explicitly or lazy.nvim silently pulls 'main' instead.
--
-- Switched off 'main' because it requires Neovim >=0.12 and
-- tree-sitter-cli >=0.26.1 — neither of which nixos-25.11 (a
-- frozen stable channel) ships yet. 'master' only needs a C
-- compiler (gcc, already in home.nix) and works fine here.
--
-- htmlangular → mapped straight to the 'angular' grammar (richer
-- than plain html: understands @if/@for, *ngIf, [binding],
-- (event), {{ interpolation }}).
--
-- Inline @Component({ template: `...` }) strings inside .ts files
-- are handled separately via after/queries/typescript/injections.scm
-- — Neovim's injection engine is core functionality, unaffected
-- by which nvim-treesitter branch is active.
-- ============================================================
vim.treesitter.language.register("angular", "htmlangular")

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	config = function()
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
			},
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
