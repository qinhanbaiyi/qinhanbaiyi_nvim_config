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
		use({
			"lewis6991/spellsitter.nvim",
			config = function()
				require("spellsitter").setup()
			end,
		})
		use({
			-- Neogen - Your Annotation Toolkit
			"danymat/neogen",
		})

		-- Nvim-tree
		use({
			"kyazdani42/nvim-tree.lua",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("nvim-tree").setup({})
			end,
		})

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
		use({ "neovim/nvim-lspconfig" })
		use({ "tami5/lspsaga.nvim" })
		use({ "williamboman/nvim-lsp-installer" })
		use({ "folke/lsp-colors.nvim" })

		-- Telescope and it's extensions
		use({ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } })
		use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

		-- UI
		use(
			-- Theme inspired by Atom
			{ "joshdick/onedark.vim" }
		)
		use("projekt0n/github-nvim-theme")
		-- Fancier statusline
		use({ "itchyny/lightline.vim" })

		-- CMP
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
				"saadparwaiz1/cmp_luasnip",
				-- "uga-rosa/cmp-dictionary",
			},
		})
		use({
			--美化自动完成提示信息
			"onsails/lspkind-nvim",
		})

		use({ "github/copilot.vim" })
		use({ "hrsh7th/cmp-buffer" })
		use({ "hrsh7th/cmp-nvim-lua" }) --nvim-cmp source for neovim Lua API.
		use({ "hrsh7th/cmp-path" })
		use({ "saadparwaiz1/cmp_luasnip" })
		-- "f3fora/cmp-spell"}) --nvim-cmp 的拼写源基于 vim 的拼写建议
		-- "hrsh7th/cmp-emoji"}) --输入: 可以显示表情
		use({ "hrsh7th/cmp-cmdline" })

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

		-- Format plugs
		use({ "nvim-lua/plenary.nvim" })
		-- use({ "p00f/cphelper.nvim" })
		use({ "mhartington/formatter.nvim" })
		use({ "jose-elias-alvarez/null-ls.nvim" })
		use({ "MunifTanjim/prettier.nvim" })
		use({ "lukas-reineke/indent-blankline.nvim" })

		-- autopairs
		use({ "windwp/nvim-autopairs" })

		-- icon in Neovim
		use({ "kyazdani42/nvim-web-devicons" })

		-- make use key easier
		use({ "folke/which-key.nvim" })

		-- barbar plugin, which makes tags upper windows
		use({ "romgrk/barbar.nvim" })

		use({ "akinsho/toggleterm.nvim" })

		-- show the history of change
		use({ "mbbill/undotree" })

		-- 代码调试
		use("puremourning/vimspector")
		-- Markdown
		use({ "ellisonleao/glow.nvim" })
		-- rust-tools
		use({ "simrat39/rust-tools.nvim" })

		-- 代码折叠插件
		use({
			"anuvyklack/pretty-fold.nvim",
			config = function()
				require("pretty-fold").setup({})
				require("pretty-fold.preview").setup()
			end,
		})

		use(
			-- show function
			"liuchengxu/vista.vim"
		)
		use( --show functional variables
			"simrat39/symbols-outline.nvim"
		)

		-- 符号匹配
		use("tpope/vim-surround")

		use({ "michaelb/sniprun", run = "bash ./install.sh" })

		-- make us pay attention to work
		use({ "junegunn/goyo.vim" })

		-- Code Debug
		use("mfussenegger/nvim-dap")
	end,
	config = {
		display = {
			open_fn = function()
				return require("packer.util").float({
					border = "single",
				})
			end,
		},
		-- git = {
		-- 	default_url_format = "git@github.com:%s",
		-- },
	},
})
