local M = {}

function M.get_current_func_node(lang)
	local parser = vim.treesitter.get_parser(0, lang)
	if not parser then
		return nil
	end
	local trees = parser:parse()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]
	local node = trees[1] and trees[1]:root():named_descendant_for_range(row, col, row, col)
	while node do
		if node:type() == "function_definition" or node:type() == "function_declaration" then
			return node
		end
		node = node:parent()
	end
end

return M
