-- 外观集中管理，默认使用 One Dark，保留原来的状态栏、标签栏与缩进线。
return {
	-- 使用 One Dark 自身默认配置；旧 Material 专用 opts 未曾生效，已经移除。
	{
		"olimorris/onedarkpro.nvim",
		config = function()
			vim.api.nvim_command("colorscheme onedark")
		end,
	},
	{
		"marko-cerovac/material.nvim", -- 保留可手动切换的备用主题。
		init = function()
			vim.g.material_style = "Palenight"
		end,
		config = false, -- 启动时不应用备用主题，避免覆盖 One Dark。
	},

	-- 状态栏保持分窗口显示，字段和分隔符沿用原设置。
	{
		"nvim-lualine/lualine.nvim",
		event = "VimEnter",
		opts = {
			options = {
				icons_enabled = true, -- 显示字体图标，终端需使用 Nerd Font。
				theme = "auto", -- 跟随当前 colorscheme，切换主题无需另改状态栏。
				-- 组件之间使用细分隔符，区域之间使用 Powerline 三角分隔符。
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {}, -- 所有文件类型均可显示状态栏。
				always_divide_middle = true, -- 即使中间区域为空也保留左右分区。
				globalstatus = false, -- 每个窗口各自显示状态栏，不占用全局单一状态行。
			},
			-- 活动窗口从左到右显示模式、Git/诊断、文件名和文件属性。
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			-- 非活动窗口只保留文件名与光标位置，方便识别而不抢占视觉注意力。
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {}, -- 顶部缓冲区标签交由 Barbar，避免两个插件重复绘制。
			extensions = {}, -- 不额外启用特殊窗口布局，沿用统一字段。
		},
		config = true,
	},

	-- 缩进线由 IBL 提供，<leader>ug 直接切换当前插件。
	{
		"lukas-reineke/indent-blankline.nvim",
		version = "v3.10.1",
		main = "ibl", -- 仓库名与 Lua 模块名不同，告诉 Lazy 使用 ibl.setup。
		keys = {
			{ "<leader>ug", "<cmd>IBLToggle<cr>", mode = "n", desc = "Toggle Indent Guides", silent = true },
		},
		event = "VimEnter",
		init = function()
			-- 保留可见空白及行尾箭头；这是编辑器选项，与 IBL 作用域线独立。
			vim.opt.list = true
			vim.opt.listchars:append("eol:↴")
		end,
		---@module "ibl"
		---@type ibl.config
		-- 保留 IBL 默认细线和 Treesitter 作用域提示；切换只控制缩进线，不改变 listchars。
		opts = {},
	},

	-- 缓冲区标签栏保留 [b / ]b、Alt-X 和 Ctrl-P 操作。
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- 提供缓冲区的 Git 修改状态。
			"nvim-tree/nvim-web-devicons", -- 提供文件类型图标。
		},
		init = function()
			vim.g.barbar_auto_setup = false -- 由 Lazy 的 opts 统一初始化，避免重复 setup。
		end,
		event = "VimEnter",
		opts = {},
		version = "^1.0.0", -- 限制为 1.x 系列；实际版本仍由 lazy-lock.json 固定。
		keys = {
			{ "[b", "<cmd>BufferPrevious<CR>", mode = "n", desc = "Previous Buffer", silent = true },
			{ "]b", "<cmd>BufferNext<CR>", mode = "n", desc = "Next Buffer", silent = true },
			{ "<A-x>", "<cmd>BufferClose<CR>", mode = "n", silent = true },
			{ "<C-p>", "<cmd>BufferPick<CR>", mode = "n", silent = true },
		},
	},
}
