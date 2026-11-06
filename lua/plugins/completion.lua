-- Blink 管理补全菜单，LuaSnip 管理片段跳转，两者各自保留原有键位。
-- 主题切换后恢复补全颜色，不让补全插件替换主主题。
local function set_highlights()
	local colors = {
		BlinkCmpLabelDeprecated = { fg = "#808080", strikethrough = true },
		BlinkCmpLabelMatch = { fg = "#569CD6" },
		BlinkCmpKindVariable = { fg = "#9CDCFE" },
		BlinkCmpKindInterface = { link = "BlinkCmpKindVariable" },
		BlinkCmpKindText = { link = "BlinkCmpKindVariable" },
		BlinkCmpKindFunction = { fg = "#C586C0" },
		BlinkCmpKindMethod = { link = "BlinkCmpKindFunction" },
		BlinkCmpKindKeyword = { fg = "#D4D4D4" },
		BlinkCmpKindProperty = { link = "BlinkCmpKindKeyword" },
		BlinkCmpKindUnit = { link = "BlinkCmpKindKeyword" },
	}
	for group, attributes in pairs(colors) do
		vim.api.nvim_set_hl(0, group, attributes)
	end
end

return {
	{
		"saghen/blink.cmp",
		version = "v1.10.2",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = { "L3MON4D3/LuaSnip" },
		init = function()
			vim.o.completeopt = "menuone,noselect"
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("BlinkCompletionHighlights", { clear = true }),
				desc = "Restore completion colors after a theme change",
				callback = set_highlights,
			})
			set_highlights()
		end,
		opts = {
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "prefer_rust" }, -- 优先 Rust 匹配器，缺失时仍能用 Lua 工作。
			-- 不套用预设，避免升级新增按键抢占片段跳转或原编辑操作。
			keymap = {
				preset = "none",
				-- 未主动选中候选时，回车继续换行；选中后才接受补全。
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = {
					function(cmp)
						if cmp.is_menu_visible() then
							return cmp.select_next({ auto_insert = true })
						end
					end,
					"fallback",
				},
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<C-d>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-e>"] = { "hide", "fallback" },
			},
			-- 保留边框、候选列与不预选的习惯；自动括号交给 mini.pairs。
			completion = {
				accept = { auto_brackets = { enabled = false } },
				list = { selection = { preselect = false, auto_insert = false } },
				menu = {
					border = "single",
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind", gap = 1 },
							{ "source_name" },
						},
					},
				},
				documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "single" } },
				ghost_text = { enabled = true, show_without_selection = true },
			},
			-- LSP、片段、路径始终参与；buffer 至少输入 4 个字符才给候选，减少噪声。
			sources = {
				default = { "lsp", "snippets", "path", "buffer" },
				-- 仅 Lua 启用模块名补全，其他语言的候选来源和排序保持不变。
				per_filetype = { lua = { "lazydev", "lsp", "snippets", "path", "buffer" } },
				providers = {
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
					snippets = { name = "LuaSnip" },
					lsp = { fallbacks = {} },
					path = { fallbacks = {} },
					buffer = { min_keyword_length = 4 },
				},
			},
			-- 冒号命令行支持补全，/ 与 ? 搜索沿用原来的输入行为。
			cmdline = {
				sources = function()
					if vim.fn.getcmdtype() == ":" then
						return { "cmdline" }
					end
					return {}
				end,
				keymap = {
					preset = "none",
					["<Tab>"] = { "show_and_insert_or_accept_single", "select_next", "fallback" },
					["<S-Tab>"] = {
						function(cmp)
							return cmp.show_and_insert_or_accept_single({ initial_selected_item_idx = -1 })
						end,
						"select_prev",
						"fallback",
					},
				},
				completion = {
					list = { selection = { preselect = false, auto_insert = true } },
					menu = { auto_show = true },
				},
			},
		},
	},
}
