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
local r_utils = require("Snippets.utils.r.utils")
local su = require("utils.lua.string")
local tl = su.box_trim_lines
local indentation = su.get_space_str(8)

local function comment(...)
	local args = { ... }
	local result = ""
	for _, arg in ipairs(args) do
		result = result .. " " .. string.gsub(arg, " ", "")
	end
	return string.gsub(vim.bo.commentstring, " %%s", "'") .. result
end

local function get_current_func_doc_comment_snip(args)
	local index = 1
	local tab = {}
	for _, arg in ipairs(string.split(args[1][1], ",")) do
		table.insert(tab, t({ comment("@param: ", arg), "" }))
		table.insert(tab, t({ "" }))
	end
	table.insert(tab, t(comment("@return: ")))
	table.insert(tab, i(index))
	return sn(nil, tab)
end

local M = {}

M = {
	s(
		"func",
		fmt(
			tl([[
			{}{}{}
			{} <- function({}) {{
			{}{}
			}}
			]]),
			{
				f(function(args)
					return "#' @description " .. args[1][1]
				end, { 1 }),
				d(3, r_utils.get_current_func_doc_comment_snip, { 2 }),
				d(5, r_utils.get_current_func_return_snip, { 4 }),
				i(1),
				i(2),
				t(indentation),
				i(4),
			}
		)
	),
	s("pp", {
		t({ "%>%", "" }),
		t({ "" }),
	}),
	s("in", {
		t("%in% "),
	}),
	s("lp", {
		t("%<>% "),
	}),
	s("tp", {
		t("%T>% "),
	}),
	s("e", {
		t("<- "),
	}),
	s({ trig = "param" }, {
		t({ "@param", "" }),
		t({ "@param", "" }),
	}, {
		condition = function(line)
			if line:match("#") then
				return true
			end
			return false
		end,
	}),
	-- s(),
	-- s(),
	-- s(),
	-- s("func", {
	-- 	c(1, {
	-- 		sn(nil, {
	-- 			t("func <- function("),
	-- 			i(1),
	-- 			t({ ") {", "" }),
	-- 			t(r_utils:get_space_str(8)),
	-- 			i(2),
	-- 			t({ "", "}" }),
	-- 		}),
	-- 		sn(nil, {
	-- 			t("func <- function("),
	-- 			i(1),
	-- 			t({ ") {", "\t" }),
	-- 			f(function(args)
	-- 				local tags = {}
	-- 				table.insert(tags, "# Args: " .. args[1][1] .. "")
	-- 				table.insert(tags, "\t# Return: " .. "")
	-- 				return tags
	-- 			end, { 1 }, {}),
	-- 			t({ "", "\t" }),
	-- 			i(2),
	-- 			t({ "", "}" }),
	-- 		}),
	-- 		-- sn(nil, {
	-- 		fmt(
	-- 			[[
	-- 	# '@Desc: {}
	-- 	# '@Params: {}
	-- 	# '@Return: {}
	-- 	func <- function({}) {{
	-- 	{}{}
	-- 	}}
	-- 	]],
	-- 			{
	-- 				i(3),
	-- 				rep(1),
	-- 				i(4),
	-- 				i(1),
	-- 				t(r_utils:get_space_str(8)),
	-- 				i(2),
	-- 			}
	-- 		),
	-- 		-- }),
	-- 	}),
	-- }),
}

return M
