-- ============================================================
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
-- because that is the filetype every .html file gets assigned in autocmds.lua.
-- ============================================================
return {
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
}
