-- Aerial 提供符号导航和左侧大纲，后端依次尝试 LSP、Tree-sitter 与文档解析。
return {
	{
		"stevearc/aerial.nvim",
		version = "v4.0.0",
		lazy = false,
		keys = {
			{ "<leader>cs", "<cmd>AerialNavToggle<cr>", desc = "Aerial Navigation Toggle" },
			{ "<leader>cS", "<cmd>AerialToggle<cr>", desc = "Aerial Toggle" },
			{ "<leader>vs", "<cmd>AerialToggle<cr>", mode = { "n", "v" }, desc = "Code Outline" },
		},
		opts = {
			attach_mode = "global", -- 切换缓冲区时复用同一个符号视图。
			backends = { "lsp", "treesitter", "markdown", "man" },
			show_guides = true,
			layout = {
				resize_to_content = false, -- 保持侧栏宽度稳定，避免符号长短导致布局跳动。
				win_opts = {
					winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
					signcolumn = "yes",
					statuscolumn = " ",
				},
				default_direction = "prefer_left",
			},
			-- stylua: ignore
			guides = {
			  mid_item   = "├╴",
			  last_item  = "└╴",
			  nested_top = "│ ",
			  whitespace = "  ",
			},
		},
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
}
