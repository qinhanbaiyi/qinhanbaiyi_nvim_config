-- 颜色选择器与 LSP 颜色高亮。此提交修复新版 Neovim 的客户端方法调用。
return {
	{
		"uga-rosa/ccc.nvim",
		commit = "9d1a256e006decc574789dfc7d628ca11644d4c2",
		lazy = false, -- 保持颜色选择器和 LSP 颜色检测在启动后可用。
		opts = {},
	},
}
