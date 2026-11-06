-- R 函数片段的 Roxygen 参数与返回值生成器；读取当前函数，返回 LuaSnip 动态节点。
local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local ts_utils = require("snippets.helpers.treesitter")
local get_node_text = vim.treesitter.get_node_text

local M = {}

-- 输入标签和从 AST 取得的文本，输出 Roxygen 注释 snippetNode。
-- 每条注释保留一个可编辑说明占位符；空列表输出空节点。
local function doc_snippet(tag, values)
	if #values == 0 then
		return ls.snippet_node(nil, ls.text_node(""))
	end
	local lines = { "\n" }
	local nodes = {}
	for index, value in ipairs(values) do
		-- 参数/表达式中的花括号是原文，先转义，避免被 fmt 当成占位符。
		value = value:gsub("[{}]", "%0%0")
		lines[#lines + 1] = string.format("#' @%s %s {}", tag, value)
		nodes[index] = ls.insert_node(index)
	end
	return ls.snippet_node(nil, fmt(table.concat(lines, "\n"), nodes))
end

-- 同时识别普通参数和带默认值参数，只提取参数名，避免把默认值写入标签。
-- 优先使用语法树字段，位置回退保留对现有 R parser 节点布局的兼容。
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

-- 保留原有规则：收集函数体直接子节点中的 return(...) 调用。
-- 嵌套分支里的 return 和 R 的隐式返回不在此扫描范围内，标签说明仍可手工补充。
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
