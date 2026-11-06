return {
	-- Snippet
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		event = { "InsertEnter" },
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local ls = require("luasnip")
			-- <c-k> is my expansion key
			-- this will expand the current item or jump to the next item within the snippet.
			local keymap = vim.keymap.set
			keymap({ "i", "s" }, "<c-k>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { silent = true, noremap = true })

			-- <c-j> is my jump backwards key.
			-- this always moves to the previous item within the snippet
			keymap({ "i", "s" }, "<c-j>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { silent = true, noremap = true })

			-- <c-l> is selecting within a list of options.
			-- This is useful for choice nodes (introduced in the forthcoming episode 2)
			keymap({ "i", "s" }, "<c-l>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				else
					vim.api.nvim_feedkeys(require("cmp.utils.keymap").t("<right>"), "n", true)
				end
			end, { noremap = true, silent = true })

			-- c()
			keymap("i", "<c-u>", require("luasnip.extras.select_choice"), { silent = true, noremap = true })

			-- shorcut to source my luasnips file again, which will reload my snippets
			keymap(
				"n",
				"<leader><leader>s",
				"<cmd>source ~/.config/nvim/lua.bak/luasnip_snippets/init.lua<CR>",
				{ silent = true, noremap = true }
			)

			-- require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/plugins/Snippets/snippets" })
			-- require("luasnip").config.setup({ store_selection_keys = "<A-p>" })

			-- vim.cmd([[command! LuaSnipEdit :lua require("luasnip.loaders.from_lua").edit_snippet_files()]])

			local types = require("luasnip.util.types")
			ls.config.set_config({
				history = true, --keep around last snippet local to jump back
				updateevents = "TextChanged,TextChangedI", --update changes as you type
				enable_autosnippets = true,
				ext_opts = { [types.choiceNode] = { active = { virt_text = { { "●", "GruvboxOrange" } } } } },
			})
			local list = { "all", "r", "lua", "tex", "python", "rust", "markdown", "go" }
			for _, lang in ipairs(list) do
				local snippet = require("plugins.Snippets.snippets." .. lang)
				ls.add_snippets(lang, snippet, { key = lang })
			end
		end,
	},
	{ "rafamadriz/friendly-snippets" },
}
