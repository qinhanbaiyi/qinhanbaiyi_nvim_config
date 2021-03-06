require("packer").reset({
	git = {
		default_url_format = "https://github.com/%s", -- Lua format string used for "aaa/bbb" style plugins
		-- default_url_format = "https://gitclone/github.com/%s", -- Lua format string used for "aaa/bbb" style plugins
	},
})
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

return require("packer").startup({
	function()
		-- Packer can manage itself
		use("wbthomason/packer.nvim")

		-- Treesitter
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
		})

		-- Nvim-tree
		use({
			"kyazdani42/nvim-tree.lua",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("nvim-tree").setup({})
			end,
		})

		-- markdown-preview
		use({ "ellisonleao/glow.nvim" })

		--[[ use({
		"davidgranstrom/nvim-markdown-preview",
		requires = "davidgranstrom/nvim-markdown-preview",
	}) ]]

		-- TEX
		-- use({
		-- 	"jakewvincent/texmagic.nvim",
		-- 	config = function()
		-- 		require("texmagic").setup({
		-- 			-- Config goes here; leave blank for defaults
		-- 		})
		-- 	end,
		-- })

		-- LSP
		use("neovim/nvim-lspconfig")

		-- Telescope and it's extensions
		use({ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } })
		use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

		-- UI to select things (files, grep results, open buffers...)
		use("joshdick/onedark.vim") -- Theme inspired by Atom
		use("itchyny/lightline.vim") -- Fancier statusline

		-- related cmp plugin download
		use({
			"onsails/lspkind-nvim", --美化自动完成提示信息
			"hrsh7th/cmp-buffer", --从buffer中智能提示
			"hrsh7th/cmp-nvim-lua", --nvim-cmp source for neovim Lua API.
			-- "octaltree/cmp-look", --用于完成英语单词
			"hrsh7th/cmp-path", --自动提示硬盘上的文件
			-- "hrsh7th/cmp-calc", --输入数学算式（如1+1=）自动计算
			-- "f3fora/cmp-spell", --nvim-cmp 的拼写源基于 vim 的拼写建议
			-- "hrsh7th/cmp-emoji", --输入: 可以显示表情
			"hrsh7th/cmp-cmdline", --use cmp-nvim in cmdline
			-- "uga-rosa/cmp-dictionary",
		})

		use({
			"hrsh7th/nvim-cmp",
			requires = {
				"hrsh7th/cmp-nvim-lsp", --neovim 内置 LSP 客户端的 nvim-cmp 源
				--以下插件可选，可以根据个人喜好删减
				"onsails/lspkind-nvim", --美化自动完成提示信息
				"hrsh7th/cmp-buffer", --从buffer中智能提示
				"hrsh7th/cmp-nvim-lua", --nvim-cmp source for neovim Lua API.
				-- "octaltree/cmp-look", --用于完成英语单词
				"hrsh7th/cmp-path", --自动提示硬盘上的文件
				"hrsh7th/cmp-calc", --输入数学算式（如1+1=）自动计算
				"f3fora/cmp-spell", --nvim-cmp 的拼写源基于 vim 的拼写建议
				"hrsh7th/cmp-emoji", --输入: 可以显示表情
				"hrsh7th/cmp-cmdline", --use cmp-nvim in cmdline
				-- "uga-rosa/cmp-dictionary",
			},
		})

		-- 代码段提示
		use({
			"L3MON4D3/LuaSnip",
			requires = {
				"saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
				"rafamadriz/friendly-snippets", --代码段合集
			},
		})

		-- Comment
		use({
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup()
			end,
		})

		-- Keyboard Layout Switch
		--[[ use({
		"lyokha/vim-xkbswitch",
	}) ]]

		-- Format plugs
		use({
			"nvim-lua/plenary.nvim",
		})
		use("mhartington/formatter.nvim")
		use("jose-elias-alvarez/null-ls.nvim")
		use("MunifTanjim/prettier.nvim")

		use("lukas-reineke/indent-blankline.nvim")

		-- autopairs
		use("windwp/nvim-autopairs")

		-- icon in Neovim
		use("kyazdani42/nvim-web-devicons")

		-- make use key easier
		use("folke/which-key.nvim")

		-- RStudio in neovim
		--[[ use("jalvesaq/Nvim-R") ]]

		-- barbar plugin, which makes tags upper windows
		use({
			"romgrk/barbar.nvim",
		})

		use({
			"williamboman/nvim-lsp-installer",
		})

		use({
			"akinsho/toggleterm.nvim",
		})

		use({
			"tami5/lspsaga.nvim",
		})

		-- spell check
		use({
			"lewis6991/spellsitter.nvim",
		})

		-- rust-tools
		use({
			"simrat39/rust-tools.nvim",
		})

		-- show the history of change
		use("mbbill/undotree")

		-- 代码调试
		-- use "puremourning/vimspector"

		--  代码函数注释插件
		use("heavenshell/vim-pydocstring")

		-- 代码折叠插件
		use({
			"anuvyklack/pretty-fold.nvim",
			config = function()
				require("pretty-fold").setup({})
				require("pretty-fold.preview").setup()
			end,
		})

		-- use("tmhedberg/SimpylFold")
		-- use("Konfekt/FastFold")
		-- use("zhimsel/vim-stay")

		-- show function
		use("liuchengxu/vista.vim")

		--show functional variables
		use("simrat39/symbols-outline.nvim")

		-- 符号匹配
		use("tpope/vim-surround")
		-- 快速选中
		-- use("gcmt/wildfire.vim")

		use({ "michaelb/sniprun", run = "bash ./install.sh" })
	end,
	config = {
		display = {
			open_fn = function()
				return require("packer.util").float({
					border = "single",
				})
			end,
		},
	},
})
