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
-- AUTOCOMMANDS
-- ============================================================
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
