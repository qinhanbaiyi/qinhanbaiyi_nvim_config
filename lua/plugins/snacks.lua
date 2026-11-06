-- Snacks 提供引用跳转与显示开关，显式固定版本以验证新版 LSP 接口兼容性。
return {
	{
		"folke/snacks.nvim",
		commit = "882c996cf28183f4d63640de0b4c02ec886d01f2",
		priority = 1000,
		lazy = false,
		keys = {
			{
				"<a-n>",
				function()
					Snacks.words.jump(vim.v.count1, true)
				end,
				desc = "Next Reference",
				mode = { "n", "v" },
				silent = true,
			},
			{
				"<a-p>",
				function()
					Snacks.words.jump(-vim.v.count1, true)
				end,
				desc = "Prev Reference",
				mode = { "n", "v" },
				silent = true,
			},
		},
		-- 等启动插件完成设置后再读取开关默认值，保持原来的显示状态。
		init = function()
			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("UserSnacksToggles", { clear = true }),
				pattern = "LazyDone",
				once = true,
				desc = "Register display toggles after startup options are applied",
				callback = function()
					Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
					Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
					Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
					Snacks.toggle.diagnostics():map("<leader>ud")
					Snacks.toggle.line_number():map("<leader>ul")
					Snacks.toggle
						.option(
							"conceallevel",
							{ off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }
						)
						:map("<leader>uc")
					Snacks.toggle
						.option(
							"showtabline",
							{ off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }
						)
						:map("<leader>uA")
					Snacks.toggle.treesitter():map("<leader>uT")
					Snacks.toggle
						.option("background", { off = "light", on = "dark", name = "Dark Background" })
						:map("<leader>ub")
					Snacks.toggle.dim():map("<leader>uD")
					Snacks.toggle.animate():map("<leader>ua")
					Snacks.toggle.scroll():map("<leader>uS")
					Snacks.toggle.profiler():map("<leader>dpp")
					Snacks.toggle.profiler_highlights():map("<leader>dph")
					if vim.lsp.inlay_hint then
						Snacks.toggle.inlay_hints():map("<leader>uh")
					end
				end,
			})
		end,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			dashboard = { enabled = false },
			indent = { enabled = false },
			input = { enabled = false },
			notifier = {
				enabled = false,
				timeout = 3000,
			},
			quickfile = { enabled = true },
			scroll = { enabled = false },
			statuscolumn = { enabled = false },
			words = { enabled = true },
			styles = {
				notification = {
					-- wo = { wrap = true } -- Wrap notifications
				},
			},
		},
	},
}
