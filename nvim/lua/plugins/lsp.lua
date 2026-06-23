-- ============================================================
-- LSP — no Mason, binaries managed by Nix
--
-- Uses vim.lsp.config() / vim.lsp.enable() (lspconfig v3+ API).
--
-- angularls requires an explicit cmd with --tsProbeLocations and
-- --ngProbeLocations pointing to node_modules. Without these,
-- ngserver starts but can't find TypeScript or Angular packages
-- and silently detaches. We build the cmd dynamically from the
-- workspace root so it works across projects.
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
-- ============================================================
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
	},
	config = function()
		-- --------------------------------------------------------
		-- On attach — keymaps + document highlight + inlay hints
		-- --------------------------------------------------------
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

				-- Disable semantic tokens: treesitter owns highlighting.
				-- Multiple servers (ts_ls, angularls, html) attaching to the
				-- same .ts buffer would cause concurrent repaint races → flicker.
				if client then
					client.server_capabilities.semanticTokensProvider = nil
				end

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

		-- --------------------------------------------------------
		-- TypeScript
		-- --------------------------------------------------------
		vim.lsp.config("ts_ls", {
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
		})
		vim.lsp.enable("ts_ls")

		-- --------------------------------------------------------
		-- Angular
		--
		-- ngserver needs --tsProbeLocations and --ngProbeLocations
		-- set to the project's node_modules. Without them it starts
		-- but immediately fails to find @angular/compiler and exits.
		-- We build the cmd per-workspace via on_new_config so it
		-- works regardless of where the project lives.
		-- --------------------------------------------------------
		vim.lsp.config("angularls", {
			filetypes = { "typescript", "htmlangular" },
			root_dir = function(fname)
				return vim.fs.dirname(
					vim.fs.find({ "angular.json", "nx.json", "project.json" }, { upward = true, path = fname })[1]
				)
			end,
			on_new_config = function(config, root)
				local probe = root .. "/node_modules"
				local cmd = {
					"ngserver",
					"--stdio",
					"--tsProbeLocations",
					probe,
					"--ngProbeLocations",
					probe,
				}
				config.cmd = cmd
			end,
		})
		vim.lsp.enable("angularls")

		-- --------------------------------------------------------
		-- HTML
		-- --------------------------------------------------------
		vim.lsp.config("html", {
			filetypes = { "html", "htmlangular" },
		})
		vim.lsp.enable("html")

		-- --------------------------------------------------------
		-- CSS
		-- --------------------------------------------------------
		vim.lsp.config("cssls", {})
		vim.lsp.enable("cssls")

		-- --------------------------------------------------------
		-- ESLint
		-- --------------------------------------------------------
		vim.lsp.config("eslint", {
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"htmlangular",
			},
		})
		vim.lsp.enable("eslint")

		-- --------------------------------------------------------
		-- Nix
		-- --------------------------------------------------------
		vim.lsp.config("nil_ls", {})
		vim.lsp.enable("nil_ls")

		-- --------------------------------------------------------
		-- Tailwind
		-- --------------------------------------------------------
		vim.lsp.config("tailwindcss", {
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
		})
		vim.lsp.enable("tailwindcss")

		-- --------------------------------------------------------
		-- Emmet
		-- Usage: type abbreviation → Tab/Enter to expand
		--   div.container   →  <div class="container"></div>
		--   ul>li*3         →  3 list items
		--   app-header      →  <app-header></app-header>
		-- --------------------------------------------------------
		vim.lsp.config("emmet_language_server", {
			filetypes = {
				"htmlangular",
				"css",
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
			},
		})
		vim.lsp.enable("emmet_language_server")

		-- --------------------------------------------------------
		-- Prisma
		-- Also: npm i -D prettier-plugin-prisma in your project
		-- Add to .prettierrc: { "plugins": ["prettier-plugin-prisma"] }
		-- --------------------------------------------------------
		vim.lsp.config("prismals", {})
		vim.lsp.enable("prismals")

		-- --------------------------------------------------------
		-- Lua
		-- --------------------------------------------------------
		vim.lsp.config("lua_ls", {
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
		})
		vim.lsp.enable("lua_ls")
	end,
}
