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
		"marko-cerovac/material.nvim",
		init = function()
			vim.g.material_style = "Palenight"
		end,
		config = false,
	},

	-- 状态栏保持分窗口显示，字段和分隔符沿用原设置。
	{
		"nvim-lualine/lualine.nvim",
		event = "VimEnter",
		opts = {
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {},
				always_divide_middle = true,
				globalstatus = false,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		},
		config = true,
	},

	-- 缩进线由 IBL 提供，<leader>ug 直接切换当前插件。
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		keys = {
			{ "<leader>ug", "<cmd>IBLToggle<cr>", mode = "n", desc = "Toggle Indent Guides", silent = true },
		},
		event = "VimEnter",
		init = function()
			vim.opt.list = true
			vim.opt.listchars:append("eol:↴")
		end,
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},

	-- 缓冲区标签栏保留 [b / ]b、Alt-X 和 Ctrl-P 操作。
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		event = "VimEnter",
		opts = {},
		version = "^1.0.0", -- optional: only update when a new 1.x version is released
		keys = {
			{ "[b", "<cmd>BufferPrevious<CR>", mode = "n", desc = "Previous Buffer", silent = true },
			{ "]b", "<cmd>BufferNext<CR>", mode = "n", desc = "Next Buffer", silent = true },
			{ "<A-x>", "<cmd>BufferClose<CR>", mode = "n", silent = true },
			{ "<C-p>", "<cmd>BufferPick<CR>", mode = "n", silent = true },
		},
	},
}
