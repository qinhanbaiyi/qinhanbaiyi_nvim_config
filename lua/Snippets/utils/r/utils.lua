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

local lua_ts_utils = require("Snippets.utils.ts_utils")
local ts_query = vim.treesitter.query

local ts_utils = require("nvim-treesitter.ts_utils")
local ts_locals = require("nvim-treesitter.locals")

local Utils = {}

-- parse_syntax_tree parse the syntax for the current changes
function Utils.refresh_syntax_tree()
	local language_tree = vim.treesitter.get_parser(0, "r")
	language_tree:parse()
end

-- get_current_func_node returns the function node at current cursor point
function Utils.get_current_func_node()
	local cursor_node = ts_utils.get_node_at_cursor()
	local scope = ts_locals.get_scope_tree(cursor_node, 0)
	local function_node
	for _, node in ipairs(scope) do
		if node:type() == "function_definition" or "program" then
			function_node = node
			break
		end
	end
	return function_node
end

local M = {}

function M:get_space_str(number_of_spaces)
	return string.format("%%-%ds", number_of_spaces):format("")
end

function M:get_current_func_doc_comment_snip()
	Utils.refresh_syntax_tree()
	local function_node = Utils.get_current_func_node()
	if not function_node then
		return sn(nil, t(""))
	end
	local query = vim.treesitter.query.parse_query(
		"r",
		[[  
(function_definition(
formal_parameters) @params)
	]]
	)
	local comment_lines = { "\n" }
	local snip_nodes = {}
	local index = 1
	for _, matches, _ in query:iter_matches(function_node, 0) do
		-- func name
		-- 这个行不通
		-- func param
		local param_node = matches[1]
		for param in param_node:iter_children() do
			if param:type() == "identifier" then
				table.insert(comment_lines, string.format("#' @param %s {}", ts_query.get_node_text(param, 0)))
				table.insert(snip_nodes, i(index))
				index = index + 1
			end
		end
	end
	-- if there are no param in the function, return nothing if #snip_nodes < 1 then
	if #snip_nodes < 1 then
		return sn(nil, t(""))
	end
	local comment_str = table.concat(comment_lines, "\n")
	return sn(nil, fmt(comment_str, snip_nodes))
end
-- M:get_current_func_return_snip
function M:get_current_func_return_snip()
	Utils.refresh_syntax_tree()
	local function_node = Utils.get_current_func_node()
	-- P(vim.treesitter.get_node_text(function_node, 0))
	if not function_node then
		return sn(nil, t(""))
	end
	local query = vim.treesitter.query.parse_query(
		"r",
		[[  
(function_definition (brace_list (call 
arguments: (arguments) @callfunc
)))
	]]
	)
	local comment_lines = { "\n" }
	local snip_nodes = {}
	local index = 1
	for _, matches, _ in query:iter_matches(function_node, 0) do
		local ret = ts_query.get_node_text(matches[1], 0)
		if not matches[1] then
			return sn(nil, t(""))
		end
		table.insert(comment_lines, string.format("#' @return %s {}", ret))
		table.insert(snip_nodes, i(index))
		index = index + 1
	end
	-- if there are no param in the function, return nothing if #snip_nodes < 1 then
	if #snip_nodes < 1 then
		return sn(nil, t(""))
	end
	local comment_str = table.concat(comment_lines, "\n")
	return sn(nil, fmt(comment_str, snip_nodes))
end
return M
