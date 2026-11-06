return {
	-- Code Debug
	{ "mfussenegger/nvim-dap" },
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
	{ "jbyuki/one-small-step-for-vimkind" },
	{ "theHamsta/nvim-dap-virtual-text" },

	-- test
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
	},

	-- develop
	{ "folke/neodev.nvim", ft = "lua" },
}
