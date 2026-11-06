-- LuaSnip 的加载入口与交互设置。自定义片段位于 lua/snippets/，不混入插件声明目录。
return {
	{
		"L3MON4D3/LuaSnip",
		-- 固定已验证的稳定版，包含 Neovim 0.12 和新版 vim.validate 的兼容修复。
		version = "v2.5.0",
		build = "make install_jsregexp",
		event = "InsertEnter",
		keys = {
			{
				"<leader><leader>s",
				function()
					require("snippets").reload()
				end,
				desc = "Reload LuaSnip snippets",
			},
		},
		-- 插件层只管理运行选项和按键；语言内容由 snippets 模块统一注册。
		config = function()
			local ls = require("luasnip")
			local types = require("luasnip.util.types")
			-- 以下四项等价于旧 history=true：记住已展开片段，允许向前/向后跨片段跳转。
			-- update_events 同时覆盖普通编辑和插入模式，参数变化后刷新依赖的动态节点。
			ls.config.set_config({
				keep_roots = true,
				link_roots = true,
				link_children = true,
				exit_roots = false,
				update_events = { "TextChanged", "TextChangedI" },
				enable_autosnippets = true,
				ext_opts = { [types.choiceNode] = { active = { virt_text = { { "●", "GruvboxOrange" } } } } },
			})
			require("snippets").load()

			-- 有活动片段时跳转占位符，否则保留原来的光标移动。
			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				elseif vim.fn.mode() == "i" then
					vim.api.nvim_feedkeys(vim.keycode("<Up>"), "n", false)
				end
			end, { silent = true, desc = "Expand snippet, jump forward or move up" })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				elseif vim.fn.mode() == "i" then
					vim.api.nvim_feedkeys(vim.keycode("<Down>"), "n", false)
				end
			end, { silent = true, desc = "Jump back in snippet or move down" })

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				else
					vim.api.nvim_feedkeys(vim.keycode("<Right>"), "n", false)
				end
			end, { silent = true, desc = "Cycle snippet choice or move right" })

			-- C-l 循环当前候选，C-u 打开完整选择列表。
			vim.keymap.set("i", "<C-u>", require("luasnip.extras.select_choice"), {
				silent = true,
				desc = "Select snippet choice",
			})
		end,
	},
}
