local ls = require("luasnip")
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/Snippets/snippets" })
require("luasnip").config.setup({ store_selection_keys = "<A-p>" })

vim.cmd([[command! LuaSnipEdit :lua require("luasnip.loaders.from_lua").edit_snippet_files()]])

local types = require("luasnip.util.types")
ls.config.set_config({
	history = true, --keep around last snippet local to jump back
	updateevents = "TextChanged,TextChangedI", --update changes as you type
	enable_autosnippets = true,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "●", "GruvboxOrange" } },
			},
		},
		-- [types.insertNode] = {
		-- 	active = {
		-- 		virt_text = { { "●", "GruvboxBlue" } },
		-- 	},
		-- },
	},
}) --}}}
require("luasnip.loaders.from_vscode").lazy_load()
local list = { "all", "r", "lua", "tex", "python", "rust" }
for _, lang in ipairs(list) do
	local snippet = require("Snippets.snippets." .. lang)
	ls.add_snippets(lang, snippet, { key = lang })
end
