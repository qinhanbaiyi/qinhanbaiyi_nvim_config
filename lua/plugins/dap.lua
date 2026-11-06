-- 调试与测试工具的插件入口，Lua 开发类型库由 plugins/lsp.lua 的 Lazydev 负责。
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
}
