-- Markdown 使用 Glow 浮窗预览，文件类型和快捷键都能触发插件加载。
return {
	{
		"ellisonleao/glow.nvim",
		ft = "markdown",
		keys = {
			{
				"<leader>mp",
				"<cmd>Glow<cr>",
				desc = "Markdown Preview",
				remap = false,
				mode = { "n", "v" },
				silent = true,
			},
		},
		opts = {},
	},
}
