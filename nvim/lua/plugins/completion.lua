return {
	"saghen/blink.cmp",
	event = "VimEnter",
	version = "1.*",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "2.*",
			build = (function()
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
			dependencies = {
				"rafamadriz/friendly-snippets",
			},
			config = function()
				require("snippets.init")
			end,
		},
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			event = "InsertEnter",
			opts = {
				suggestion = { enabled = false },
				panel = { enabled = false },
			},
		},
		"giuxtaposition/blink-cmp-copilot",
	},
	opts = {
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			trigger = {
				show_on_insert_on_trigger_character = true,
			},
			list = {
				selection = {
					preselect = true,
					auto_insert = true,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 100,
			},
		},
		sources = {
			default = {
				"lsp",
				"path",
				"snippets",
				"buffer",
				"copilot",
			},
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-cmp-copilot",
					score_offset = 100,
					async = true,
				},
			},
		},
		snippets = {
			preset = "luasnip",
		},
		fuzzy = {
			implementation = "lua",
		},
		signature = {
			enabled = true,
		},
	},
}
