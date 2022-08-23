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
local lua_utils = require("Snippets.utils")

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

local text = {}
text.in_comment = function()
	-- local line = vim.api.
	if line_to_cursor:match("#") then
		return true
	end
	return false
end

M = {
	s("pp", {
		t({ "%>%", "" }),
		t({ "" }),
		-- isn(1, t({ "%>%", "" }), "\t"),
	}),
	-- s("foo", {
	-- 	t({ "just a test", "" }),
	-- 	t({ "" }),
	-- 	-- isn(1, t({ "%>%", "" }), "\t"),
	-- }),
	s("in", {
		t("%in% "),
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
	-- s(),
	s(
		"func",
		fmt(
			[[
		{}
		{} <- function({}) {{
		{}{}
		}}
		]],
			{
				d(4, get_current_func_doc_comment_snip, { 2 }),
				i(1, "func"),
				i(2),
				t(lua_utils:get_space_str(8)),
				i(3),
			}
		)
	),
	s("func", {
		c(1, {
			sn(nil, {
				t("func <- function("),
				i(1),
				t({ ") {", "" }),
				t(lua_utils:get_space_str(8)),
				i(2),
				t({ "", "}" }),
			}),
			sn(nil, {
				t("func <- function("),
				i(1),
				t({ ") {", "\t" }),
				f(function(args)
					local tags = {}
					table.insert(tags, "# Args: " .. args[1][1] .. "")
					table.insert(tags, "\t# Return: " .. "")
					return tags
				end, { 1 }, {}),
				t({ "", "\t" }),
				i(2),
				t({ "", "}" }),
			}),
			-- sn(nil, {
			fmt(
				[[
		# '@Desc: {}
		# '@Params: {}
		# '@Return: {}
		func <- function({}) {{
		{}{}
		}}
		]],
				{
					i(3),
					rep(1),
					i(4),
					i(1),
					t(lua_utils:get_space_str(8)),
					i(2),
				}
			),
			-- }),
		}),
	}),
}

return M
