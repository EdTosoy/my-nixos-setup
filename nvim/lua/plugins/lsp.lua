-- ============================================================
-- LSP — no Mason, all binaries via Nix
--
-- Uses vim.lsp.config() / vim.lsp.enable() (lspconfig v3+ API).
-- require("lspconfig") is deprecated and removed in v3.
--
-- ANGULAR SETUP:
--   ngserver requires --tsProbeLocations and --ngProbeLocations
--   pointing to the project's node_modules. Without them it
--   attaches but silently produces no completions or diagnostics.
--   on_new_config builds the cmd dynamically per workspace root.
--
--   Your project also needs @angular/language-service installed:
--     npm install @angular/language-service@<same-as-@angular/core> --save-dev
--
-- DIAGNOSTICS:
--   Angular LS takes 5-15 seconds to fully analyze a project
--   after attaching. If you open a file and see nothing, wait
--   a few seconds then move your cursor — errors will appear.
--   <leader>e  → open diagnostic float under cursor
--   ]e / [e    → jump to next/prev diagnostic
--
-- home.nix packages needed:
--   typescript-language-server  → ts_ls
--   angular-language-server     → angularls
--   vscode-langservers-extracted → html, cssls, eslint
--   nodePackages."@tailwindcss/language-server" → tailwindcss
--   emmet-language-server       → emmet_language_server
--   nodePackages.prisma         → prismals
--   nil                         → nil_ls
--   lua-language-server         → lua_ls
-- ============================================================
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
	},
	config = function()
		-- --------------------------------------------------------
		-- On attach — keymaps, highlights, inlay hints
		-- --------------------------------------------------------
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("grn", vim.lsp.buf.rename, "Rename")
				map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })
				map("grD", vim.lsp.buf.declaration, "Go to declaration")
				map("K", vim.lsp.buf.hover, "Hover docs")

				local client = vim.lsp.get_client_by_id(event.data.client_id)

				-- Disable semantic tokens: treesitter owns syntax highlighting.
				-- Multiple servers attaching to the same buffer (ts_ls + angularls
				-- + html on a .ts file) would each send their own semantic token
				-- updates, causing paint races and flicker on every keystroke.
				if client then
					client.server_capabilities.semanticTokensProvider = nil
				end

				-- Highlight references to the word under cursor
				if client and client:supports_method("textDocument/documentHighlight", event.buf) then
					local hl = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
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
						group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
						callback = function(ev)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = ev.buf })
						end,
					})
				end

				-- Toggle inlay hints
				if client and client:supports_method("textDocument/inlayHint", event.buf) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "Toggle inlay hints")
				end
			end,
		})

		-- --------------------------------------------------------
		-- TypeScript / JavaScript
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
		-- Angular Language Server
		--
		-- on_new_config builds the cmd with probe locations so
		-- ngserver can find @angular/language-service and
		-- typescript in the project's node_modules.
		--
		-- root_dir is nil-guarded: returns nil (don't start) for
		-- non-Angular TypeScript files. Without the guard, passing
		-- nil to vim.fs.dirname crashes the entire LSP startup
		-- chain and kills treesitter highlighting on the buffer.
		-- --------------------------------------------------------
		vim.lsp.config("angularls", {
			filetypes = { "typescript", "html", "htmlangular" },

			root_markers = {
				"angular.json",
				"nx.json",
				"project.json",
			},

			on_new_config = function(config, root)
				local probe = root .. "/node_modules"

				config.cmd = {
					"ngserver",
					"--stdio",
					"--tsProbeLocations",
					probe,
					"--ngProbeLocations",
					probe,
				}
			end,
		})
		vim.lsp.enable("angularls")

		-- --------------------------------------------------------
		-- HTML — attribute completions for htmlangular too
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
		-- Terraform
		-- --------------------------------------------------------
		vim.lsp.config("terraformls", {
			cmd = { "terraform-ls", "serve" },
			filetypes = { "tf" },
			root_markers = {
				".terraform",
				".git",
				"terraform.tf",
				"main.tf",
			},

			on_attach = function()
				print("terraformls attached")
			end,
		})

		vim.lsp.enable("terraformls")

		-- --------------------------------------------------------
		-- Tailwind CSS
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
		-- Type abbreviation in insert mode then Tab/Enter:
		--   div.container  →  <div class="container"></div>
		--   ul>li*3        →  3 <li> items
		--   app-header     →  <app-header></app-header>
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
		-- Requires in project: npm i -D prettier-plugin-prisma
		-- Requires in .prettierrc: { "plugins": ["prettier-plugin-prisma"] }
		-- --------------------------------------------------------
		vim.lsp.config("prismals", {})
		vim.lsp.enable("prismals")

		-- --------------------------------------------------------
		-- Lua (for editing this config)
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
