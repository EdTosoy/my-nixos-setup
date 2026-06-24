return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function() return vim.fn.executable("make") == 1 end,
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

		local b = require("telescope.builtin")

		vim.keymap.set("n", "<leader>sf", b.find_files,   { desc = "Search files" })
		vim.keymap.set("n", "<leader>sg", b.live_grep,    { desc = "Search by grep" })
		vim.keymap.set("n", "<leader>sh", b.help_tags,    { desc = "Search help" })
		vim.keymap.set("n", "<leader>sk", b.keymaps,      { desc = "Search keymaps" })
		vim.keymap.set("n", "<leader>ss", b.builtin,      { desc = "Search Telescope pickers" })
		vim.keymap.set("n", "<leader>sd", b.diagnostics,  { desc = "Search diagnostics" })
		vim.keymap.set("n", "<leader>sr", b.resume,       { desc = "Search resume" })
		vim.keymap.set("n", "<leader>s.", b.oldfiles,     { desc = "Search recent files" })
		vim.keymap.set("n", "<leader>sc", b.commands,     { desc = "Search commands" })
		vim.keymap.set("n", "<leader><leader>", b.buffers, { desc = "Find open buffers" })
		vim.keymap.set({ "n", "v" }, "<leader>sw", b.grep_string, { desc = "Search current word" })

		-- LSP pickers (buffer-local, set on attach)
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("telescope-lsp", { clear = true }),
			callback = function(event)
				local buf = event.buf
				vim.keymap.set("n", "grr", b.lsp_references,              { buffer = buf, desc = "LSP references" })
				vim.keymap.set("n", "gri", b.lsp_implementations,         { buffer = buf, desc = "LSP implementations" })
				vim.keymap.set("n", "grd", b.lsp_definitions,             { buffer = buf, desc = "LSP definitions" })
				vim.keymap.set("n", "gO",  b.lsp_document_symbols,        { buffer = buf, desc = "Document symbols" })
				vim.keymap.set("n", "gW",  b.lsp_dynamic_workspace_symbols, { buffer = buf, desc = "Workspace symbols" })
				vim.keymap.set("n", "grt", b.lsp_type_definitions,        { buffer = buf, desc = "LSP type definitions" })
			end,
		})

		vim.keymap.set("n", "<leader>/", function()
			b.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10, previewer = false,
			}))
		end, { desc = "Fuzzy search current buffer" })

		vim.keymap.set("n", "<leader>s/", function()
			b.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
		end, { desc = "Search in open files" })

		vim.keymap.set("n", "<leader>sn", function()
			b.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "Search Neovim config files" })
	end,
}
