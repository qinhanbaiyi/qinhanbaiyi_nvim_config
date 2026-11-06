-- Lua/R 动态片段共享的 AST 定位层，不包含某种语言的文档格式。
local M = {}

-- 输入 Tree-sitter 语言名，返回光标所在的最近一层函数节点；函数外返回 nil。
-- 调用方需安装对应 parser。每次重新 parse，确保片段输入尚未保存时也读取最新内容。
function M.get_current_func_node(lang)
	local parser = vim.treesitter.get_parser(0, lang)
	if not parser then
		return nil
	end
	local trees = parser:parse()
	local cursor = vim.api.nvim_win_get_cursor(0)
	-- Neovim 光标行号从 1 开始，Tree-sitter 行号从 0 开始；列号均按字节计数。
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
