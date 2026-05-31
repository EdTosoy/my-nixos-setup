-- ============================================================
-- Personal Neovim Config
-- Based on kickstart.nvim
-- NixOS | Real Programmers Dvorak | One Dark Pro
-- ============================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- ============================================================
-- OPTIONS
-- ============================================================
vim.o.number = true
vim.o.relativenumber = true -- relative numbers help with jump motions (5j, 3k)
vim.o.mouse = "a"
vim.o.showmode = false -- mode shown in statusline already
vim.o.breakindent = true
vim.o.undofile = true -- persistent undo across sessions
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 251
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.wrap = true
vim.o.linebreak = true
vim.opt.swapfile = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Sync clipboard with system (wl-clipboard on Wayland)
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- ============================================================
-- FILETYPE DETECTION
-- ============================================================
-- ALL .html files → htmlangular
-- Single source of truth — every plugin references 'htmlangular' consistently
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.html",
	callback = function()
		vim.bo.filetype = "htmlangular"
	end,
})

-- ============================================================
-- KEYMAPS
-- ============================================================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save
vim.keymap.set("n", "<leader>,", "<cmd>w<CR>", { desc = "[W]rite file" })

-- Close buffer
vim.keymap.set("n", "<leader>;", "<cmd>bd<CR>", { desc = "Close buffer" })

-- Close other buffers
vim.keymap.set("n", "<leader>y", "<cmd>%bd|e#|bd#<CR>", { desc = "Close other buffers" })

-- Buffer navigation
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<CR>", { desc = "Prev buffer" })

-- Splits
vim.keymap.set("n", "<leader>o", "<cmd>vsplit<CR>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>k", "<cmd>split<CR>", { desc = "Split horizontal" })

-- Comment (Ctrl+/ like VSCode — terminal may send <C-_>)
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment selection" })
vim.keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment selection" })

-- Smart Enter between tags
-- <div>| + Enter → <div>\n  |\n</div>
vim.keymap.set("i", "<CR>", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local before = line:sub(1, col)
	local after = line:sub(col + 1)
	if before:match(">$") and after:match("^</") then
		return "<CR><Esc>O"
	end
	return "<CR>"
end, { expr = true, desc = "Smart Enter between tags" })

-- Diagnostics navigation
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text = true,
	virtual_lines = false,
	jump = { float = true },
})

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })

-- ============================================================
-- AUTOCOMMANDS
-- ============================================================
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ============================================================
-- PLUGIN MANAGER (lazy.nvim)
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- PLUGINS
-- ============================================================
require("lazy").setup({

	{ "NMAC427/guess-indent.nvim", opts = {} },

	-- --------------------------------------------------------
	-- GIT
	-- --------------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local map = function(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end
				map("n", "]h", gs.next_hunk, "Next git [H]unk")
				map("n", "[h", gs.prev_hunk, "Prev git [H]unk")
				map("n", "<leader>hs", gs.stage_hunk, "[H]unk [S]tage")
				map("n", "<leader>hr", gs.reset_hunk, "[H]unk [R]eset")
				map("n", "<leader>hp", gs.preview_hunk, "[H]unk [P]review")
				map("n", "<leader>hb", gs.blame_line, "[H]unk [B]lame line")
				map("n", "<leader>hd", gs.diffthis, "[H]unk [D]iff")
			end,
		},
	},

	-- --------------------------------------------------------
	-- WHICH-KEY
	-- --------------------------------------------------------
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			delay = 0,
			icons = { mappings = vim.g.have_nerd_font },
			spec = {
				{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "gr", group = "LSP Actions", mode = { "n" } },
			},
		},
	},

	-- --------------------------------------------------------
	-- TELESCOPE
	-- --------------------------------------------------------
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf
					vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
					vim.keymap.set(
						"n",
						"gri",
						builtin.lsp_implementations,
						{ buffer = buf, desc = "[G]oto [I]mplementation" }
					)
					vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
					vim.keymap.set(
						"n",
						"gO",
						builtin.lsp_document_symbols,
						{ buffer = buf, desc = "Open Document Symbols" }
					)
					vim.keymap.set(
						"n",
						"gW",
						builtin.lsp_dynamic_workspace_symbols,
						{ buffer = buf, desc = "Open Workspace Symbols" }
					)
					vim.keymap.set(
						"n",
						"grt",
						builtin.lsp_type_definitions,
						{ buffer = buf, desc = "[G]oto [T]ype Definition" }
					)
				end,
			})

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- --------------------------------------------------------
	-- HARPOON 2
	-- --------------------------------------------------------
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon [A]dd file" })
			vim.keymap.set("n", "<leader>d", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon [D]isplay menu" })

			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon file 1" })
			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon file 2" })
			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon file 3" })
			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon file 4" })
			vim.keymap.set("n", "<leader>5", function()
				harpoon:list():select(5)
			end, { desc = "Harpoon file 5" })
		end,
	},

	-- --------------------------------------------------------
	-- HTML / ANGULAR — auto close + rename tags
	-- per_filetype ensures htmlangular gets the same treatment as html
	-- --------------------------------------------------------
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
			per_filetype = {
				["htmlangular"] = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = true,
				},
			},
		},
	},

	-- --------------------------------------------------------
	-- LSP — no Mason, binaries managed by Nix
	--
	-- home.nix packages:
	--   typescript-language-server              → ts_ls
	--   angular-language-server                 → angularls
	--   vscode-langservers-extracted            → html, cssls, eslint
	--   nodePackages."@tailwindcss/language-server" → tailwindcss
	--   emmet-language-server                   → emmet_language_server
	--   nodePackages.prisma                     → prismals
	--   nil                                     → nil_ls
	--   lua-language-server                     → lua_ls
	--   prettierd, stylua                       → formatters
	--   gcc                                     → Treesitter parser builds
	--
	-- NOTE: All HTML-related servers explicitly list 'htmlangular'
	-- because that is the filetype every .html file gets assigned above.
	-- --------------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("K", vim.lsp.buf.hover, "Hover docs")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local hl = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = hl,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = hl,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(ev)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = ev.buf })
							end,
						})
					end

					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local servers = {
				-- TypeScript — auto-imports and full completions
				ts_ls = {
					settings = {
						typescript = {
							suggest = {
								autoImports = true,
								includeCompletionsForModuleExports = true,
								includeCompletionsWithInsertText = true,
							},
							preferences = { importModuleSpecifier = "non-relative" },
						},
						javascript = {
							suggest = {
								autoImports = true,
								includeCompletionsForModuleExports = true,
							},
						},
					},
				},

				-- Angular — explicit filetypes so it attaches to htmlangular buffers
				angularls = {
					root_dir = require("lspconfig.util").root_pattern("angular.json", "nx.json", "project.json"),
					filetypes = { "typescript", "htmlangular" },
				},

				-- html LSP — htmlangular so it attaches for attribute completions
				html = {
					filetypes = { "html", "htmlangular" },
				},

				-- CSS LSP
				cssls = {},

				-- ESLint — lint TypeScript and templates
				eslint = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"htmlangular",
					},
				},

				nil_ls = {},

				-- Tailwind — htmlangular is the filetype for all .html files
				tailwindcss = {
					filetypes = {
						"htmlangular",
						"css",
						"typescript",
						"javascript",
						"typescriptreact",
						"javascriptreact",
					},
					settings = {
						tailwindCSS = {
							experimental = {
								classRegex = {
									{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
									{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^'\"]*)(?:'|\"|`)" },
								},
							},
						},
					},
				},

				-- Emmet — works through blink.cmp completions
				-- Usage: type abbreviation in insert mode → Tab/Enter to expand
				--   div.container   →  <div class="container"></div>
				--   ul>li*3         →  3 list items
				--   app-header      →  <app-header></app-header>
				emmet_language_server = {
					filetypes = {
						"htmlangular",
						"css",
						"javascript",
						"typescript",
						"javascriptreact",
						"typescriptreact",
					},
				},

				-- Prisma — schema completions, hover docs, go-to-definition
				-- Install: nodePackages.prisma in home.nix
				-- Also install prettier-plugin-prisma in your project:
				--   npm i -D prettier-plugin-prisma
				-- Add to .prettierrc: { "plugins": ["prettier-plugin-prisma"] }
				prismals = {},

				lua_ls = {
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end
						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = vim.api.nvim_get_runtime_file("", true),
							},
						})
					end,
					settings = { Lua = {} },
				},
			}

			for name, server in pairs(servers) do
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end
		end,
	},

	-- --------------------------------------------------------
	-- FORMATTING
	-- htmlangular = the filetype for all .html files
	-- prisma formatter requires prettier-plugin-prisma in project
	-- --------------------------------------------------------
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				end
				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				htmlangular = { "prettierd" }, -- ALL .html files
				css = { "prettierd" },
				json = { "prettierd" },
				jsonc = { "prettierd" },
				markdown = { "prettierd" },
				yaml = { "prettierd" },
				prisma = { "prettierd" }, -- requires prettier-plugin-prisma
			},
		},
	},

	-- --------------------------------------------------------
	-- COMPLETION — blink.cmp
	-- --------------------------------------------------------
	{
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
				opts = {},
			},
		},
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				trigger = {
					show_on_insert_on_trigger_character = true,
				},
				list = {
					selection = { preselect = true, auto_insert = true },
				},
				documentation = { auto_show = true, auto_show_delay_ms = 100 },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					htmlangular = { "lsp", "path", "snippets", "buffer" },
					typescript = { "lsp", "path", "snippets", "buffer" },
					css = { "lsp", "path", "snippets", "buffer" },
					prisma = { "lsp", "path", "snippets", "buffer" },
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	-- --------------------------------------------------------
	-- COLORSCHEME — One Dark Pro Night Flat
	-- bg overridden to #1e1e1e to match Night Flat exactly
	-- --------------------------------------------------------
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000,
		config = function()
			require("onedarkpro").setup({
				colors = {
					bg = "#1e1e1e",
					bg_float = "#1e1e1e",
				},
				styles = {
					comments = "italic",
					keywords = "italic",
					functions = "NONE",
					variables = "NONE",
				},
				options = {
					bold = true,
					italic = true,
				},
			})
			vim.cmd.colorscheme("onedark_dark")
		end,
	},

	-- --------------------------------------------------------
	-- TODO COMMENTS
	-- --------------------------------------------------------
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
			keywords = {
				NOTE = { icon = "󰋽 ", color = "hint" },
			},
		},
	},

	-- --------------------------------------------------------
	-- MINI.NVIM
	-- --------------------------------------------------------
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
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
	},

	-- --------------------------------------------------------
	-- TREESITTER
	--
	-- NixOS fix: add gcc to home.nix so parsers can compile:
	--   home.packages = with pkgs; [ gcc ];
	--
	-- Parsers included:
	--   prisma  — schema syntax highlighting
	--   angular — Angular template syntax
	--   html    — base HTML (needed by htmlangular)
	-- --------------------------------------------------------
	{
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
				"jsonc",
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
	},
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
-- vim: ts=2 sts=2 sw=2 et
