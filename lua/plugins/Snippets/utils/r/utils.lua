local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local ts_utils = require("plugins.Snippets.utils.ts_utils")
local get_node_text = vim.treesitter.get_node_text

local M = {}

local function doc_snippet(tag, values)
	if #values == 0 then
		return ls.snippet_node(nil, ls.text_node(""))
	end
	local lines = { "\n" }
	local nodes = {}
	for index, value in ipairs(values) do
		value = value:gsub("[{}]", "%0%0")
		lines[#lines + 1] = string.format("#' @%s %s {}", tag, value)
		nodes[index] = ls.insert_node(index)
	end
	return ls.snippet_node(nil, fmt(table.concat(lines, "\n"), nodes))
end

function M:get_space_str(number_of_spaces)
	return string.format("%%-%ds", number_of_spaces):format("")
end

function M:get_current_func_doc_comment_snip()
	local fn = ts_utils.get_current_func_node("r")
	local parameters = fn and (fn:field("parameters")[1] or fn:named_child(0))
	local names = {}
	if parameters then
		for param in parameters:iter_children() do
			local name = param:type() == "identifier" and param or param:field("name")[1]
			if name then
				names[#names + 1] = get_node_text(name, 0)
			end
		end
	end
	return doc_snippet("param", names)
end

function M:get_current_func_return_snip()
	local fn = ts_utils.get_current_func_node("r")
	local body = fn and (fn:field("body")[1] or fn:named_child(1))
	local values = {}
	if body then
		for node in body:iter_children() do
			if node:type() == "call" then
				local name = node:field("function")[1]
				local arguments = node:field("arguments")[1]
				if name and arguments and get_node_text(name, 0) == "return" then
					values[#values + 1] = get_node_text(arguments, 0)
				end
			end
		end
	end
	return doc_snippet("return", values)
end

return M
