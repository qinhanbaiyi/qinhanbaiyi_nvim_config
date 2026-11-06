return {
	-- CMP
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"onsails/lspkind-nvim", --美化自动完成提示信息
			"hrsh7th/cmp-buffer", --从buffer中智能提示
			"hrsh7th/cmp-path", --自动提示硬盘上的文件
			"hrsh7th/cmp-cmdline", --use cmp-nvim in cmdline
			"saadparwaiz1/cmp_luasnip",
			-- "uga-rosa/cmp-dictionary",
		},
		event = { "InsertEnter", "CmdlineEnter" },
		config = function()
			vim.o.completeopt = "menuone,noselect"
			-- gray
			vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
			-- blue
			vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
			vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
			-- light blue
			vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
			vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
			vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
			-- pink
			vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
			vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
			-- front
			vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
			vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
			vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })

			-------------------------------------------------------------------------------
			------------------------------ RUNTIME-PATH -----------------------------------
			-------------------------------------------------------------------------------
			-- lua Language server protocol
			local runtime_path = vim.split(package.path, ";")
			table.insert(runtime_path, "lua/?.lua")
			table.insert(runtime_path, "lua/?/init.lua")
			-------------------------------------------------------------------------------
			--------------------------- FORMAT AND SETTING --------------------------------
			-------------------------------------------------------------------------------
			-- Set completeopt to have a better completion experience

			local lspkind = require("lspkind")
			local cmp = require("cmp")

			-- nvim-cmp setup
			-- @lspkind1
			local types = require("cmp.types")
			local str = require("cmp.utils.str")
			local lspkind1 = {
				format = lspkind.cmp_format({
					menu = {
						buffer = "[Buffer]",
						luasnip = "[LuaSnip]",
						latex_symbols = "[Latex]",
						nvim_lsp = "[LSP]",
						nvim_lua = "[Lua]",
						path = "[path]",
					},
					before = function(entry, vim_item)
						-- Get the full snippet (and only keep first line)
						local word = entry:get_insert_text()
						-- if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
						-- 	word = vim.lsp.util.parse_snippet(word)
						-- end
						word = str.oneline(word)
						if
							entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet
							and string.sub(vim_item.abbr, -1, -1) == "~"
						then
							word = word .. "~"
						end
						vim_item.abbr = word
						return vim_item
					end,
				}),
				-- fields = { "kind", "abbr", "menu" },
			}
			cmp.setup({
				formatting = lspkind1,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-e>"] = cmp.mapping.close(),
					["<CR>"] = cmp.mapping.confirm({
						-- behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Replace, select = false })
						else
							fallback()
						end
					end,
					["<S-Tab>"] = cmp.mapping(
						cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, select = false }),
						{ "i", "s" }
					),
				},
				sources = {
					{ name = "nvim_lsp", group_index = 1, priority = 80 },
					{ name = "luasnip", group_index = 1, priority = 80 },
					{
						name = "buffer",
						keyword_length = 4,
						option = {
							get_bufnrs = function()
								local bufs = {}
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									bufs[vim.api.nvim_win_get_buf(win)] = true
								end
								return vim.tbl_keys(bufs)
							end,
						},
						group_index = 2,
					},
					{ name = "nvim_lsp_signature_help", group_index = 1, priority = 80 },
					{ name = "path" },
					{ name = "nvim_lua" },

					-- { name = "cmp_tabnine" },
					--{name = "calc"},
					--{name = "spell"},
					--{name = "emoji"}
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				experimental = {
					ghost_text = true,
				},
			})
			cmp.setup.cmdline(":", {
				sources = {
					{ name = "cmdline" },
					{ name = "nvim_lsp", group_index = 1, priority = 80 },
					{
						name = "buffer",
						keyword_length = 2,
						option = {
							get_bufnrs = function()
								local bufs = {}
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									bufs[vim.api.nvim_win_get_buf(win)] = true
								end
								return vim.tbl_keys(bufs)
							end,
						},
						group_index = 1,
					},
					{ name = "path" },
					-- { name = "cmp_tabnine" },
					-- { name = "calc" },
					{ name = "otter" },
				},
				mapping = {
					["<Tab>"] = {
						c = function(_)
							if cmp.visible() then
								if #cmp.get_entries() == 1 then
									cmp.confirm({ select = true })
								else
									cmp.select_next_item()
								end
							else
								cmp.complete()
								if #cmp.get_entries() == 1 then
									cmp.confirm({ select = true })
								end
							end
						end,
					},
					["<S-Tab>"] = {
						c = function(_)
							if cmp.visible() then
								if #cmp.get_entries() == 1 then
									cmp.confirm({ select = true })
								else
									cmp.select_prev_item()
								end
							else
								cmp.complete()
								if #cmp.get_entries() == 1 then
									cmp.confirm({ select = true })
								end
							end
						end,
					},
				},
			})
		end,
	},
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-nvim-lua" },
	{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-nvim-lua" },
	{ "hrsh7th/cmp-path" },
	-- { "saadparwaiz1/cmp_luasnip" },
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

	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = "rafamadriz/friendly-snippets",
		-- use a release tag to download pre-built binaries
		version = "v0.*",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = nil,
	},
}
