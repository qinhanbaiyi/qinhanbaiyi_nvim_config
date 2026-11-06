-- 旧 Codeium/Windsurf Vim 插件已归档，改用仍在维护的 NeoCodeium。
-- 继续使用同一服务与本地账号，补全菜单仍由 Blink 管理，AI 只显示灰色行内建议。
return {
	{
		"monkoose/neocodeium",
		commit = "ab8a3da3a66d299ad5422b76ce5ee21b68719296",
		event = "BufEnter",
		opts = function()
			return {
				-- 保留旧开关，测试通过 --cmd 关闭 AI 后不会下载服务或发起请求。
				enabled = vim.g.codeium_enabled ~= false and vim.g.codeium_enabled ~= 0,
				-- 可选本地服务路径，默认由插件管理二进制，不在仓库写机器路径。
				bin = vim.g.neocodeium_bin,
				manual = vim.g.codeium_manual == true or vim.g.codeium_manual == 1,
				show_label = false, -- 不增加候选计数标签，保持原来的界面。
				debounce = true, -- 连续输入时合并请求，避免每个字符都触发网络请求。
				max_lines = -1, -- 原配置没有按文件行数关闭 AI。
				filter = function(bufnr)
					-- 兼容旧的全局/缓冲区开关；NeoCodeium 自身的开关也继续有效。
					return vim.g.codeium_enabled ~= false
						and vim.g.codeium_enabled ~= 0
						and vim.b[bufnr].codeium_enabled ~= false
						and vim.b[bufnr].codeium_enabled ~= 0
				end,
			}
		end,
		config = function(_, opts)
			require("config.ai").setup(opts)
		end,
	},
}
