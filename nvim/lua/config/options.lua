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
