return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			vim.treesitter.language.register("angular", "htmlangular")
			vim.treesitter.language.register("terraform", "tf")
			vim.treesitter.language.register("hcl", "tfvars")

			local ensure_installed = {
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
				"terraform",
				"python",
				"hcl",
			}

			require("nvim-treesitter").setup()
			require("nvim-treesitter").install(ensure_installed)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function()
					local ok = pcall(vim.treesitter.start)
					if ok then
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@function.outer"] = "V",
						["@class.outer"] = "V",
					},
				},
				move = {
					set_jumps = true,
				},
			})

			local select = require("nvim-treesitter-textobjects.select")
			vim.keymap.set({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end)

			local move = require("nvim-treesitter-textobjects.move")
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				move.goto_next_start("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end)
		end,
	},
}
