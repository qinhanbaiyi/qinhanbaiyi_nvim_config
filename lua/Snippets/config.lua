local ls = require("luasnip")
local types = require("luasnip.util.types")

ls.config.set_config({
	-- This tells LuaSnip to remember to keep around the last snippet.
	-- You can jump back into it even if you move outside of the selection
	history = true,

	-- This one is cool cause if you have dynamic snippets, it updates as you type!
	updateevents = "TextChanged,TextChangedI",

	-- Autosnippets:
	enable_autosnippets = true,

	-- Crazy highlights!!
	-- #vid3
	-- ext_opts = nil,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { " <- Current Choice", "NonTest" } },
			},
		},
	},
})
require("luasnip.loaders.from_vscode").lazy_load()
local snippets = {}
snippets = {
	all = require("Snippets.snippets.all"),
	lua = require("Snippets.snippets.lua"),
	rust = require("Snippets.snippets.rust"),
	markdown = require("Snippets.snippets.markdown"),
	latex = require("Snippets.snippets.latex"),
	r = require("Snippets.snippets.r"),
}
ls.add_snippets("all", snippets.all, { key = "all" })
ls.add_snippets("rust", snippets.rust, { key = "rust" })
ls.add_snippets("lua", snippets.lua, { key = "lua" })
ls.add_snippets("markdown", snippets.markdown, { key = "markdown" })
ls.add_snippets("tex", snippets.latex, { key = "tex" })
ls.add_snippets("r", snippets.r, { key = "r" })
