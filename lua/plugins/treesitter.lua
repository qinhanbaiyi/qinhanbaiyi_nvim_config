-- 解析器、语法高亮、增量选区与文本对象集中配置，新增语言先检查解析器列表。
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
	},
	{
		"MeanderingProgrammer/treesitter-modules.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			ensure_installed = {
				"bash",
				"bibtex",
				"c",
				"cpp",
				"css",
				"diff",
				"go",
				"html",
				"json",
				"latex",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"r",
				"regex",
				"rust",
				"snakemake",
				"toml",
				"vim",
				"vimdoc",
				"yaml",
			},
			-- 保留原来的语言例外：不自动安装 JavaScript，C/Rust 不启用语法树高亮。
			auto_install = true,
			ignore_install = { "javascript" },
			highlight = { enable = true, disable = { "c", "rust" } },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn",
					node_incremental = "<CR>",
					scope_incremental = "grc",
					node_decremental = "<BS>",
				},
			},
		},
	},
	{ "nvim-treesitter/nvim-treesitter-context" },
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<C-v>",
					},
					include_surrounding_whitespace = true,
				},
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			for key, capture in pairs({
				af = "@function.outer",
				["if"] = "@function.inner",
				ac = "@class.outer",
				ic = "@class.inner",
			}) do
				vim.keymap.set({ "x", "o" }, key, function()
					select.select_textobject(capture, "textobjects")
				end, { desc = "Select " .. capture:sub(2) })
			end
			vim.keymap.set({ "x", "o" }, "as", function()
				select.select_textobject("@local.scope", "locals")
			end, { desc = "Select language scope" })

			local swap = require("nvim-treesitter-textobjects.swap")
			vim.keymap.set("n", "<leader>a", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap with next parameter" })
			vim.keymap.set("n", "<leader>A", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap with previous parameter" })

			local move = require("nvim-treesitter-textobjects.move")
			-- 普通 Git 缓冲区的 [c / ]c 会被 Gitsigns 局部映射接管；可视模式仍跳转类。
			local movements = {
				goto_next_start = { "]f", "]c", "]a" },
				goto_next_end = { "]F", "]C", "]A" },
				goto_previous_start = { "[f", "[c", "[a" },
				goto_previous_end = { "[F", "[C", "[A" },
			}
			local captures = { "@function.outer", "@class.outer", "@parameter.inner" }
			for name, keys in pairs(movements) do
				local jump = move[name]
				for index, key in ipairs(keys) do
					local capture = captures[index]
					vim.keymap.set({ "n", "x", "o" }, key, function()
						jump(capture, "textobjects")
					end, { desc = name:gsub("_", " ") .. " " .. capture:sub(2) })
				end
			end
		end,
	},
	{ "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} },
}
