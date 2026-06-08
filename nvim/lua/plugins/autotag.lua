-- ============================================================
-- HTML / ANGULAR — auto close + rename tags
-- per_filetype ensures htmlangular gets the same treatment as html
-- ============================================================
return {
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
}
