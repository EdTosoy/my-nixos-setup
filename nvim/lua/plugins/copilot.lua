return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = { enabled = false }, -- blink will handle display
			panel = { enabled = false },
		},
	},
	{
		"giuxtaposition/blink-cmp-copilot",
		dependencies = { "zbirenbaum/copilot.lua" },
	},
}
