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
local su = require("utils.lua.string")
local tl = su.box_trim_lines
local indentation = su.get_space_str(vim.opt.softtabstop:get())

local lua = {}
lua = {
	s("req", {
		t("local "),
		f(function(import_name)
			local parts = vim.split(import_name[1][1], ".", true)
			return parts[#parts] or ""
		end, { 1 }),
		t({ " = require('" }),
		i(1),
		t("')"),
	}),
	s(
		"M",
		fmt(
			tl([[
		local M = {{}}
		{}
		return M
		]]),
			{
				i(1),
			}
		)
	),
	s(
		"func",
		fmt(
			tl([[
		{}{}
		function {}({}) 
		{}{}
		end
		]]),
			{
				f(function(args)
					return "-- " .. args[1][1] .. " "
				end, { 1 }),
				d(4, lua_utils.get_current_func_doc_comment_snip, { 2 }),
				i(1),
				i(2),
				t(lua_utils:get_space_str(8)),
				i(3),
			}
		)
	),
	s(
		"localfunc",
		fmt(
			tl([[
                    -- {} {}{}
                    local {} = function({})
                        {}{}
                    end
                ]]),
			{
				rep(1),
				i(4),
				d(5, lua_utils.get_current_func_doc_comment_snip, { 2 }),
				i(1),
				i(2),
				t(indentation),
				i(3),
			}
		)
	),
}
return lua
