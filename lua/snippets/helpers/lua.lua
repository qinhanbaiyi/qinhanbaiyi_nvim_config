-- Lua 函数片段的参数文档生成器；函数定位由共用 Tree-sitter helper 完成。
local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local treesitter = require("snippets.helpers.treesitter")

local M = {}

-- 作为 dynamicNode 回调使用：参数占位符变化时，重新读取当前缓冲区的函数语法树。
-- 返回 snippetNode，每个具名参数包含类型（默认 any）和说明两个可编辑占位符。
-- 尚未形成完整函数或没有具名参数时返回空节点，允许用户继续输入。
function M:get_current_func_doc_comment_snip()
	local fn = treesitter.get_current_func_node("lua")
	local parameters = fn and fn:field("parameters")[1]
	if not parameters then
		return ls.snippet_node(nil, ls.text_node(""))
	end
	local lines = { "\n" }
	local nodes = {}
	for node in parameters:iter_children() do
		if node:type() == "identifier" then
			local name = vim.treesitter.get_node_text(node, 0)
			-- fmt 中的双花括号输出字面量花括号，单花括号留给下面的插入节点。
			lines[#lines + 1] = string.format("-- @param {{ {} }} %s {}", name)
			nodes[#nodes + 1] = ls.insert_node(#nodes + 1, "any")
			nodes[#nodes + 1] = ls.insert_node(#nodes + 1)
		end
	end
	if #nodes == 0 then
		return ls.snippet_node(nil, ls.text_node(""))
	end
	return ls.snippet_node(nil, fmt(table.concat(lines, "\n"), nodes))
end

return M
