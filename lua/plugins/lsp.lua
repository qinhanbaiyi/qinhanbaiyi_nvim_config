-- 插件版本、依赖和加载时机；服务器参数与原生快捷键在 config/lsp.lua。
return {
	-- Mason 管理服务器安装，nvim-lspconfig 提供配置，Neovim 原生 API 启用服务。
	{
		"neovim/nvim-lspconfig",
		version = "v2.12.0",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"saghen/blink.cmp",
			{ "mason-org/mason.nvim", version = "v2.3.1", opts = {} },
			{ "mason-org/mason-lspconfig.nvim", version = "v2.3.0" },
		},
		init = function()
			require("config.lsp").init()
		end,
		config = function()
			require("config.lsp").setup()
		end,
	},
	{
		"folke/lazydev.nvim",
		commit = "ff2cbcba459b637ec3fd165a2be59b7bbaeedf0d",
		ft = "lua",
		opts = {
			-- 按当前文件使用的模块加载 LuaLS 类型，Neovim 类型来自自身 runtime。
			library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
			integrations = { cmp = false },
		},
	},
	{
		"nvimdev/lspsaga.nvim",
		commit = "cf6fc9473bba1d332eda9887855ea29ed9b37701",
		lazy = false, -- 保持原来的启动时加载。
		cmd = "Lspsaga",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		-- Saga 界面操作归插件所有，保留普通、可视和选择模式中的原有键位。
		keys = {
			{
				"gd",
				"<cmd>Lspsaga peek_definition<CR>",
				mode = { "n", "v" },
				desc = "Preview Definition",
				silent = true,
				remap = false,
			},
			{
				"gr",
				"<cmd>Lspsaga finder ref<CR>",
				mode = { "n", "v" },
				desc = "References",
				silent = true,
				nowait = true,
			},
			{ "gI", "<cmd>Lspsaga finder imp<CR>", mode = { "n", "v" }, desc = "Goto Implementation", silent = true },
			{
				"gy",
				"<cmd>Lspsaga peek_type_definition<CR>",
				mode = { "n", "v" },
				desc = "Goto T[y]pe Definition",
				silent = true,
			},
			{ "gD", "<cmd>Lspsaga goto_definition<CR>", mode = { "n", "v" }, desc = "Go to Definition", silent = true },
			{
				"gh",
				"<cmd>Lspsaga hover_doc<CR>",
				mode = { "n", "v" },
				desc = "Lsp Hover",
				silent = true,
				remap = false,
			},
			{
				"<leader>cr",
				"<cmd>Lspsaga rename<cr>",
				mode = { "n", "v" },
				desc = "Rename",
				silent = true,
				remap = false,
			},
			{
				"<leader>ca",
				"<cmd>Lspsaga code_action<CR>",
				mode = { "n", "v" },
				desc = "Code Action",
				silent = true,
				remap = false,
			},
			{ "<leader>co", "<cmd>Lspsaga outline<cr>", mode = "n", desc = "Lsp Outline", silent = true },
			{ "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", mode = "n", desc = "Prev Diagnostic", silent = true },
			{ "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", mode = "n", desc = "Next Diagnostic", silent = true },
		},
		config = function(_, opts)
			require("lspsaga").setup(opts)
			require("config.lsp_compat").setup()
		end,
		opts = {
			finder = { methods = {} },
			-- 上游改过预览窗口的默认键位，显式保留原来的操作。
			definition = {
				keys = {
					edit = "<C-c>o",
					vsplit = "<C-c>v",
					split = "<C-c>i",
					tabe = "<C-c>t",
					tabnew = "<C-c>n",
					quit = "q",
					close = "<C-c>k",
				},
			},
		},
	},
	{
		"ray-x/lsp_signature.nvim",
		commit = "1997451c4c9956a1380d8bea4b0e33ebdf07976e",
		event = "VeryLazy",
		-- 上游默认宽度已调整；保持原来的签名浮窗宽度和自动提示。
		opts = { max_width = 80 },
	},
	-- 维护中的 symbols-outline 后继；保留旧命令、右侧宽度和折叠操作。
	{
		"hedyhli/outline.nvim",
		commit = "03ce1482222dc2bf1f781559508301f05382936d",
		cmd = {
			"Outline",
			"OutlineOpen",
			"OutlineClose",
			"SymbolsOutline",
			"SymbolsOutlineOpen",
			"SymbolsOutlineClose",
		},
		opts = {
			outline_window = { position = "right", width = 25, relative_width = true, auto_close = false },
			preview_window = { auto_preview = false, winhl = "NormalFloat:Pmenu" },
			symbol_folding = { autofold_depth = false, auto_unfold = { hovered = true, only = false } },
		},
		config = function(_, opts)
			local outline = require("outline")
			outline.setup(opts)
			for name, action in pairs({
				SymbolsOutline = outline.toggle_outline,
				SymbolsOutlineOpen = outline.open_outline,
				SymbolsOutlineClose = outline.close_outline,
			}) do
				vim.api.nvim_create_user_command(name, function()
					action()
				end, { desc = "Outline compatibility command" })
			end
		end,
	},
}
