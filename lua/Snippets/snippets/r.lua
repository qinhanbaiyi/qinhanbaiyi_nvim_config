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

local M = {}

local function lines(args, parent, old_state, initial_text)
	local nodes = {}
	old_state = old_state or {}

	-- count is nil for invalid input.
	local count = tonumber(args[1][1])
	-- Make sure there's a number in args[1].
	if count then
		for j = 1, count do
			local iNode
			if old_state and old_state[j] then
				-- old_text is used internally to determine whether
				-- dependents should be updated. It is updated whenever the
				-- node is left, but remains valid when the node is no
				-- longer 'rendered', whereas node:get_text() grabs the text
				-- directly from the node.
				iNode = i(j, old_state[j].old_text)
			else
				iNode = i(j, initial_text)
			end
			nodes[2 * j - 1] = iNode

			-- linebreak
			nodes[2 * j] = t({ "", "" })
			-- Store insertNode in old_state, potentially overwriting older
			-- nodes.
			old_state[j] = iNode
		end
	else
		nodes[1] = t("Enter a number!")
	end

	local snip = sn(nil, nodes)
	snip.old_state = old_state
	return snip
end

local function get_space_str(number_of_spaces)
	return string.format("%%-%ds", number_of_spaces):format("")
end

M = {
	s("pp", {
		isn(1, t({ "%>%", "" }), "\t"),
	}),
	s("in", {
		t("%in% "),
	}),
	s("e", {
		t("<- "),
	}),
	-- s("func", {
	-- 	t("func <- function("),
	-- 	i(1),
	-- 	t({ ") {", "\t" }),
	-- 	f(function(args, snip)
	-- 		local tags = {}
	-- 		table.insert(tags, "# Args: " .. args[1][1] .. "")
	-- 		table.insert(tags, "\t# Return: " .. "")
	-- 		return tags
	-- 	end, { 1 }, {}),
	-- 	t({ "", "\t" }),
	-- 	i(2),
	-- 	t({ "", "}" }),
	-- }),
	s("trig", {
		i(1, "1"),
		-- pos, function, argnodes, opts (containing the user_arg).
		d(2, lines, { 1 }, { user_args = { "what waht" } }),
	}),
	-- @WRAN
	s(
		"func",
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
				t(get_space_str(4)),
				i(2),
			}
		)
	),
	-- s("func", {
	-- 	t("func <- function("),
	-- 	i(1),
	-- 	t({ ") {", "\t" }),
	-- 	d(2, function(args, snip, user_arg1)
	-- 		local out = {}
	-- 		out[1] = "# Args: " .. args[1]
	-- 		out[2] = user_arg1
	-- 	end, { 1 }),
	-- }),
}

return M
