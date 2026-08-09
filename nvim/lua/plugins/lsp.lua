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
		-- Python — basedpyright (type checking/completions) + ruff (lint/format)
		-- --------------------------------------------------------
		vim.lsp.config("basedpyright", {
			root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
			settings = {
				basedpyright = {
					analysis = {
						venvPath = ".",
						venv = ".venv",
						autoImportCompletions = true,
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						typeCheckingMode = "standard",
					},
					disableTaggedHints = true,
				},
			},
		})
		vim.lsp.enable("basedpyright")

		vim.lsp.config("ruff", {
			filetypes = { "python" },
			on_attach = function(client)
				client.server_capabilities.hoverProvider = false
			end,
		})
		vim.lsp.enable("ruff")

		-- --------------------------------------------------------
		-- Lua (for editing this config)
		-- --------------------------------------------------------
		vim.lsp.config("lua_ls", {
			on_init = function(client)
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if path ~= vim.fn.stdpath("config") and (vim.uv.fs_stat(path .. "/.luarc.json")) then
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

		-- --------------------------------------------------------
		-- Markdown
		-- --------------------------------------------------------
		vim.lsp.config("marksman", {})
		vim.lsp.enable("marksman")

		-- --------------------------------------------------------
		-- Bash
		-- --------------------------------------------------------
		vim.lsp.config("bashls", {
			filetypes = { "sh", "bash" },
		})
		vim.lsp.enable("bashls")
	end,
}
