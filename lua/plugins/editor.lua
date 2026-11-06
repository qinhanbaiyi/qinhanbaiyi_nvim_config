-- 日常编辑工具按功能集中声明，插件专属键位与其配置放在一起。
return {
	-- 注释模板生成器。优先使用 Neovim 原生片段接口，保留 cn/ng 两个入口。
	{
		"danymat/neogen",
		cmd = "Neogen",
		keys = {
			{
				"<leader>cn",
				function()
					require("neogen").generate()
				end,
				desc = "Generate Annotations (Neogen)",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>ng",
				":Neogen<cr>",
				desc = "Annotation Toolkit",
				remap = false,
				mode = { "n", "v" },
				silent = true,
			},
		},
		opts = function(_, opts)
			if opts.snippet_engine ~= nil then
				return
			end

			opts.snippet_engine = "luasnip"

			if vim.snippet then
				opts.snippet_engine = "nvim"
			end
		end,
	},

	-- 文件树保留启动加载，plenary/nui 提供底层能力，devicons 提供图标。
	{
		"nvim-neo-tree/neo-tree.nvim",
		keys = {
			{
				"<leader>e",
				"<cmd>Neotree toggle<cr>",
				desc = "Neo-Tree",
				remap = false,
				mode = { "n", "v" },
				silent = true,
			},
		},
		event = "VimEnter",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
	},

	-- 原 Comment.nvim 从未执行 setup；现有 gc/gcc 本就由 Neovim 原生提供。
	-- 移除未启用的重复依赖，不添加原先不存在的 gb 键位。

	-- 自动补齐成对括号与引号，使用维护组织的新仓库和固定稳定版。
	{ "nvim-mini/mini.pairs", version = "v0.18.0", opts = {} },

	-- 用 gsa/gsd/gsr 等操作包围符，避免与普通 s/r 命令冲突。
	{
		"nvim-mini/mini.surround",
		version = "v0.18.0",
		config = function(_, opts)
			require("mini.surround").setup(opts)
			-- v0.17 起不再自动创建此键，保留 gsn 调整搜索范围的原操作。
			vim.keymap.set("n", "gsn", "<Cmd>lua MiniSurround.update_n_lines()<CR>", {
				desc = "Update surrounding search lines",
				silent = true,
			})
		end,
		opts = {
			mappings = {
				add = "gsa",
				delete = "gsd",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				replace = "gsr",
			},
		},
	},
	-- 终端窗口插件保留现有默认设置，需要时通过 ToggleTerm 命令打开。
	{
		"akinsho/toggleterm.nvim",
		commit = "066cccf48a43553a80a210eb3be89a15d789d6e6",
		init = function(plugin)
			-- 模块加载前应用固定源码的局部校验补丁，不改动磁盘插件文件。
			require("config.plugin_patches").register(plugin, require("config.compat.toggleterm"))
		end,
		config = true,
	},
}
