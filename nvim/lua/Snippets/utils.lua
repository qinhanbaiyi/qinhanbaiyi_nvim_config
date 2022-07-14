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
local fmt = require("luasnip.extras.fmt").fmt
local m = require("luasnip.extras").m
local lambda = require("luasnip.extras").l
local postfix = require("luasnip.extras.postfix").postfix

local M = {}

-- parse_syntax_tree parse the syntax for the current changes
function M:refresh_syntax_tree()
	local language_tree = vim.treesitter.get_parser(0, "lua")
	language_tree:parse()
end

function string.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if delimiter == "" then
		return false
	end
	local pos, arr = 0, {}
	for st, sp in
		function()
			return string.find(input, delimiter, pos, true)
		end
	do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

local function comment(...)
	local args = { ... }
	local result = ""
	for _, arg in ipairs(args) do
		result = result .. arg
	end
	return string.gsub(vim.bo.commentstring, "%%s", "") .. result
end

function M:get_current_func_doc_comment_snip(args)
	local index = 1
	local tab = {}
	for _, arg in ipairs(string.split(args[1][1], ",")) do
		table.insert(tab, t({ comment(" @Param: ", arg), "" }))
		table.insert(tab, t({ "" }))
	end
	table.insert(tab, t(comment(" @Return: ")))
	table.insert(tab, i(index))
	return sn(nil, tab)
end

-- the usage of dynamic node
function M:lines(args, parent, old_state, initial_text)
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

function M:get_space_str(number_of_spaces)
	return string.format("%%-%ds", number_of_spaces):format("")
end

return M
