return {
	-- Neogen - Your Annotation Toolkit
	{
		"danymat/neogen",
		cmd = "Neogen",
		keys = {},
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

	-- Neo tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		event = "VimEnter",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
	},

	-- Codeium
	{
		"Exafunction/codeium.vim",
		event = "BufEnter",
		config = function()
			vim.keymap.set("i", "<c-g>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, silent = true })
			vim.keymap.set("i", "<a-n>", function()
				return vim.fn["codeium#CycleCompletions"](1)
			end, { expr = true, silent = true })
			vim.keymap.set("i", "<a-N>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true, silent = true })
			vim.keymap.set("i", "<c-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true, silent = true })
		end,
	},

	-- Comment
	{ "numToStr/Comment.nvim", event = "BufEnter" },

	-- Auto pairs
	{ "echasnovski/mini.pairs", version = "*", opts = {} },

	-- Surround
	{
		"echasnovski/mini.surround",
		opts = {
			mappings = {
				add = "gsa",
				delete = "gsd",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				replace = "gsr",
				update_n_lines = "gsn",
			},
		},
	},
	-- Float term
	{ "akinsho/toggleterm.nvim", version = "*", config = true },
}
