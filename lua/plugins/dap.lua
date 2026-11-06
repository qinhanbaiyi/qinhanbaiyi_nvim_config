-- 调试与测试工具的插件入口，Lua 开发类型库由 plugins/lsp.lua 的 Lazydev 负责。
return {
	-- 调试框架与界面。语言 adapter、启动参数应按具体项目补充。
	{ "mfussenegger/nvim-dap" },
	{
		"rcarriga/nvim-dap-ui",
		-- v4.0.0 尚未修复旧 validate，固定已验证的新签名兼容提交。
		commit = "cc9dd33aade7f20bae414d0cba163bc60d4d4b43",
		dependencies = {
			"mfussenegger/nvim-dap",
			-- 稳定版已移除旧 validate；供 DAP UI 等工具复用异步任务接口。
			{ "nvim-neotest/nvim-nio", version = "v1.10.1" },
		},
	},
	{
		"jbyuki/one-small-step-for-vimkind",
		-- 当前维护分支为 main。只安装 Lua 调试工具，不自动启动服务或注册 adapter。
		branch = "main",
		commit = "1af6ffb9b5229a856e8090fa2f690e0931a5aace",
	},
	{ "theHamsta/nvim-dap-virtual-text" },

	-- 测试运行框架。当前只声明通用依赖，语言测试 adapter 需另外配置。
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
	},
}
