local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
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

local snippets = {}
snippets = {
	all = require("luasnip_snippets.snippets.all"),
	-- all = require("luasnip_snippets.snippets.all"),
	lua = require("luasnip_snippets.snippets.lua"),
	rust = require("luasnip_snippets.snippets.rust"),
	markdown = require("luasnip_snippets.snippets.markdown"),
	latex = require("luasnip_snippets.snippets.latex"),
}
ls.add_snippets("all", snippets.all, { key = "all" })
ls.add_snippets("rust", snippets.rust, { key = "rust" })
ls.add_snippets("lua", snippets.lua, { key = "lua" })
ls.add_snippets("markdown", snippets.markdown, { key = "markdown" })
ls.add_snippets("tex", snippets.latex, { key = "tex" })
