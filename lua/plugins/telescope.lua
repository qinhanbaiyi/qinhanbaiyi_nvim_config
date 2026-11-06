-- 查找与搜索的键位集中在这里，保留启动加载及现有搜索排序行为。
return {

	-- Telescope and it's extensions
	{
		"nvim-telescope/telescope.nvim",
		lazy = false,
		keys = {
			{
				"<leader>,",
				"<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
				desc = "Switch Buffer",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>:",
				"<cmd>Telescope command_history<cr>",
				desc = "Command History",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>fb",
				"<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
				desc = "Find File buffer",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>ff",
				"<cmd>Telescope find_files<cr>",
				desc = "Find Files",
				remap = false,
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>fg",
				"<cmd>Telescope git_files<cr>",
				desc = "File Files (git files)",
				remap = false,
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>fr",
				"<cmd>Telescope oldfiles<cr>",
				desc = "File Recent",
				remap = false,
				mode = { "n", "v" },
				silent = true,
			},
			{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits", mode = { "n", "v" }, silent = true },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status", mode = { "n", "v" }, silent = true },
			{ '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers", mode = { "n", "v" }, silent = true },
			{
				"<leader>sa",
				"<cmd>Telescope autocommands<cr>",
				desc = "Auto Commands",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>sb",
				"<cmd>Telescope current_buffer_fuzzy_find<cr>",
				desc = "Buffer",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>sc",
				"<cmd>Telescope command_history<cr>",
				desc = "Command History",
				mode = { "n", "v" },
				silent = true,
			},
			{ "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands", mode = { "n", "v" }, silent = true },
			{
				"<leader>sd",
				"<cmd>Telescope diagnostics bufnr=0<cr>",
				desc = "Document Diagnostics",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>sD",
				"<cmd>Telescope diagnostics<cr>",
				desc = "Workspace Diagnostics",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<leader>sg",
				"<cmd>Telescope live_grep<cr>",
				desc = "File Live-grep",
				remap = false,
				mode = { "n", "v" },
				silent = true,
			},
			{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages", mode = { "n", "v" }, silent = true },
			{
				"<leader>sH",
				"<cmd>Telescope highlights<cr>",
				desc = "Search Highlight Groups",
				mode = { "n", "v" },
				silent = true,
			},
			{ "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist", mode = { "n", "v" }, silent = true },
			{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps", mode = { "n", "v" }, silent = true },
			{ "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List", mode = { "n", "v" }, silent = true },
			{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages", mode = { "n", "v" }, silent = true },
			{ "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark", mode = { "n", "v" }, silent = true },
			{ "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options", mode = { "n", "v" }, silent = true },
			{ "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume", mode = { "n", "v" }, silent = true },
			{ "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List", mode = { "n", "v" }, silent = true },
			{ "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Find Luasnips", mode = { "n", "v" }, silent = true },
			{
				"<leader>ft",
				"<cmd>Telescope treesitter<cr>",
				desc = "Lists Function names, variables, from Treesitter",
				mode = { "n", "v" },
				silent = true,
			},
		},
		tag = "v0.2.1",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			extensions = {
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					-- the default case_mode is "smart_case"
				},
				luasnip = {
					luasnip = true,
				},
			},
		},
	},
	{ "nvim-telescope/telescope-fzf-native.nvim" },
	{
		"benfowler/telescope-luasnip.nvim",
	},
	{ "nvim-telescope/telescope-dap.nvim" },
}
