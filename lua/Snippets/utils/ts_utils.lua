local ts_utils = require("nvim-treesitter.ts_utils")
local ts_locals = require("nvim-treesitter.locals")

local Utils = {}

-- parse_syntax_tree parse the syntax for the current changes
function Utils.refresh_syntax_tree()
	local language_tree = vim.treesitter.get_parser(0, "lua")
	language_tree:parse()
end

-- get_current_func_node returns the function node at current cursor point
function Utils.get_current_func_node()
	local cursor_node = ts_utils.get_node_at_cursor()
	local scope = ts_locals.get_scope_tree(cursor_node, 0)

	local function_node

	for _, node in ipairs(scope) do
		if node:type() == "function_definition" or node:type() == "function_declaration" then
			function_node = node
			break
		end
	end

	return function_node
end

return Utils
