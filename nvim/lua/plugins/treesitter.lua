-- ============================================================
-- TREESITTER
--
-- NixOS fix: add gcc to home.nix so parsers can compile:
--   home.packages = with pkgs; [ gcc ];
--
-- Parsers included:
--   prisma  — schema syntax highlighting
--   angular — Angular template syntax
--   html    — base HTML (needed by htmlangular)
--
-- NOTE: 'jsonc' is not a separate installable parser — Neovim maps
-- the jsonc filetype to the 'json' grammar automatically (see the
-- FileType autocmd below, via vim.treesitter.language.get_lang).
-- ============================================================
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main",
	config = function()
		local parsers = {
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
			"yaml",
			"nix",
			"prisma",
		}
		require("nvim-treesitter").install(parsers)
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf, filetype = args.buf, args.match
				local language = vim.treesitter.language.get_lang(filetype)
				if not language then
					return
				end
				if not vim.treesitter.language.add(language) then
					return
				end
				vim.treesitter.start(buf, language)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
