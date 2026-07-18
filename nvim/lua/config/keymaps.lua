vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save / close
vim.keymap.set("n", "<leader>,", "<cmd>w<CR>", { desc = "Write file" })
vim.keymap.set("n", "<leader>;", "<cmd>bd<CR>", { desc = "Close buffer" })
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

-- Smart Enter between tags: <div>| + Enter → <div>\n  |\n</div>
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

-- Diagnostics
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })

vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text = {
		severity = { min = vim.diagnostic.severity.HINT },
		prefix = "●",
	},
	signs = true,
	jump = { float = true },
})

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })
