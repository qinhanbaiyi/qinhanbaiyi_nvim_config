local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- These exist to more easily reuse functionNode-functions
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local rep = require("luasnip.extras").rep
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local m = require("luasnip.extras").m
local lambda = require("luasnip.extras").l
local postfix = require("luasnip.extras.postfix").postfix
local lua_utils = require("Snippets.utils.lua.utils")

local function get_current_func_doc_comment_snip(args)
	local index = 1
	local tab = {}
	table.insert(tab, t({ "'''", "" }))
	table.insert(tab, t({ lua_utils:get_space_str(4) }))
	for _, arg in ipairs(string.split(args[1][1], ",")) do
		table.insert(tab, t({ "@param: " .. string.gsub(arg, " ", ""), "" }))
		table.insert(tab, t({ lua_utils:get_space_str(4) }))
	end
	table.insert(tab, t("@return: "))
	table.insert(tab, i(index))
	table.insert(tab, t({ "", "" }))
	table.insert(tab, t({ lua_utils:get_space_str(4) .. "'''" }))
	return sn(nil, tab)
end

local M = {}

M = {
	s(
		"func",
		fmt(
			[[
		def {}({}) {}:
		{}{}
		{}{}
		]],
			{
				i(1, "func"),
				i(2),
				c(3, {
					t(""),
					sn(nil, {
						t("-> "),
						i(1),
					}),
				}),
				t(lua_utils:get_space_str(4)),
				d(4, get_current_func_doc_comment_snip, { 2 }),
				t(lua_utils:get_space_str(4)),
				i(5, "pass"),
			}
		)
	),
}

return M
