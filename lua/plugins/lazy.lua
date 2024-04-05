local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/playground",
			"nvim-treesitter/nvim-treesitter-context",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
	},
	"nvim-treesitter/playground",
	"nvim-treesitter/nvim-treesitter-context",
	"nvim-treesitter/nvim-treesitter-textobjects",
	{ "windwp/nvim-ts-autotag" },
	{
		"lewis6991/spellsitter.nvim",
		config = function()
			require("spellsitter").setup()
		end,
	},
	-- Neogen - Your Annotation Toolkit
	{ "danymat/neogen" },

	-- Nvim-tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Refactor
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},

	-- LSP
	{ "neovim/nvim-lspconfig" },
	{
		"glepnir/lspsaga.nvim",
		branch = "main",
		config = function()
			require("lspsaga").setup({})
		end,
	},
	"williamboman/mason.nvim",
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
	{ "folke/lsp-colors.nvim" },
	{ "ray-x/lsp_signature.nvim" },
	{ "RRethy/vim-illuminate" }, -- highlight the word under the cursor

	-- Telescope and it's extensions
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ "nvim-telescope/telescope-fzf-native.nvim" },
	{
		"benfowler/telescope-luasnip.nvim",
		module = "telescope._extensions.luasnip", -- if you wish to lazy-load
	},
	{ "nvim-telescope/telescope-dap.nvim" },

	-- Git
	{ "lewis6991/gitsigns.nvim" },
	{ "sindrets/diffview.nvim" },

	-- Copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({})
		end,
	},

	-- diagnose
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	},

	-- UI
	-- Theme inspired by Atom
	{ "olimorris/onedarkpro.nvim" },
	{ "marko-cerovac/material.nvim" },
	{ "projekt0n/github-nvim-theme" },
	-- Fancier statusline
	{ "nvim-lualine/lualine.nvim" },

	-- Jump
	-- { "ggandor/leap.nvim" },
	{
		"folke/flash.nvim",
		-- event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		-- stylua: ignore
		keys = {
		  { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
		  { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
		  { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
		  { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
		  { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		}
,
	},

	-- CMP
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"onsails/lspkind-nvim", --美化自动完成提示信息
			"hrsh7th/cmp-buffer", --从buffer中智能提示
			"hrsh7th/cmp-path", --自动提示硬盘上的文件
			"hrsh7th/cmp-calc", --输入数学算式（如1+1=）自动计算
			"f3fora/cmp-spell", --nvim-cmp 的拼写源基于 vim 的拼写建议
			"hrsh7th/cmp-emoji", --输入: 可以显示表情
			"hrsh7th/cmp-cmdline", --use cmp-nvim in cmdline
			"saadparwaiz1/cmp_luasnip",
			-- "uga-rosa/cmp-dictionary",
		},
	},
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-nvim-lsp-signature-help",
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-nvim-lua" },
	{ "hrsh7th/cmp-path" },
	{ "saadparwaiz1/cmp_luasnip" },
	{ "hrsh7th/cmp-cmdline" },
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},

	--美化自动完成提示信息
	{ "onsails/lspkind-nvim" },

	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	},
	{ "rafamadriz/friendly-snippets" },

	-- Comment
	{ "numToStr/Comment.nvim" },

	-- Format plugs
	{ "nvim-lua/plenary.nvim" },
	{ "mhartington/formatter.nvim" },
	{ "jose-elias-alvarez/null-ls.nvim" },
	{ "MunifTanjim/prettier.nvim" },
	{ "lukas-reineke/indent-blankline.nvim" },

	-- autopairs
	{ "windwp/nvim-autopairs" },

	-- make use key easier
	{ "folke/which-key.nvim" },

	-- barbar plugin, which makes tags upper windows
	{ "romgrk/barbar.nvim" },

	{ "akinsho/toggleterm.nvim", version = "*", config = true },

	-- show the history of change
	{ "mbbill/undotree" },

	-- Markdown
	{
		"ellisonleao/glow.nvim",
		config = function()
			require("glow").setup({ glow_path = "/home/baiyi/go/bin/glow" })
		end,
	},
	-- rust-tools
	{ "simrat39/rust-tools.nvim", ft = "rust" },

	-- show function
	{ "liuchengxu/vista.vim" },
	--show functional variables
	{ "simrat39/symbols-outline.nvim" },

	-- 符号匹配
	"tpope/vim-surround",

	{ "michaelb/sniprun", branch = "master", build = "sh install.sh" },

	-- make us pay attention to work
	{ "junegunn/goyo.vim" },

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

	-- go plugin
	{ "ray-x/go.nvim", ft = "go" },
	{ "ray-x/guihua.lua", ft = "go" },

	-- mark
	{ "chentoast/marks.nvim" },

	-- color display and change
	{
		"uga-rosa/ccc.nvim",
		config = function()
			require("ccc").setup()
		end,
	},
})
