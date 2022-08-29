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
local ts_utils = require("nvim-treesitter.ts_utils")
local ts_locals = require("nvim-treesitter.locals")

local function get_method_node()
	local curr_node = ts_utils.get_node_at_cursor()
	local scope = ts_locals.get_scope_tree(curr_node, 0)
	local method_node = nil

	for _, node in ipairs(scope) do
		if node:type() == "function_definition" or node:type() == "function_declaration" then
			method_node = node
		end
	end
	return method_node
end

local function get_method_info()
	local method_node = get_method_node()
	if not method_node then
		return
	end
	local query = vim.treesitter.query.parse_query(
		"lua",
		[[  
(function_declaration
(parameters
(identifier) @params
))
	]]
	)
	local param_info = {}
	for _, matches, _ in query:iter_matches(method_node, 0) do
		local param_node = matches[1]
		table.insert(param_info, {
			param = vim.treesitter.query.get_node_text(param_node, 0),
		})
	end
	return {
		param_info = param_info,
	}
end

local function get_doc()
	local doc_info = get_method_info()
	local doc = {}
	--TODO: 可以修改完善
	for _, params in pairs(doc_info.param_info) do
		for _, param in pairs(params) do
			table.insert(doc, "--@param " .. param)
		end
	end
	return doc
end

-- P(get_doc())
-- i(vim.lsp.get_active_clients())
