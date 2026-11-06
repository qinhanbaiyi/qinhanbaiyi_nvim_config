-- Python 函数片段；保留原有四空格缩进、返回类型选择和参数说明布局。
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local strings = require("snippets.helpers.string")

-- dynamicNode 的 args[1] 对应函数参数占位符，内容按逗号拆分为逐行参数说明。
-- 输出完整 docstring 的 snippetNode，返回值说明保留一个可编辑占位符。
local function get_current_func_doc_comment_snip(args)
	local index = 1
	local tab = {}
	table.insert(tab, t({ "'''", "" }))
	table.insert(tab, t({ strings.get_space_str(4) }))
	for _, arg in ipairs(vim.split(args[1][1], ",")) do
		table.insert(tab, t({ "@param: " .. string.gsub(arg, " ", ""), "" }))
		table.insert(tab, t({ strings.get_space_str(4) }))
	end
	table.insert(tab, t("@return: "))
	table.insert(tab, i(index))
	table.insert(tab, t({ "", "" }))
	table.insert(tab, t({ strings.get_space_str(4) .. "'''" }))
	return sn(nil, tab)
end

return {
	s(
		"func",
		fmt(
			[[
		def {}({}) {}:
		{}{}
		{}{}
		]],
			{
				i(1, "func"),
				i(2),
				c(3, {
					t(""),
					sn(nil, {
						t("-> "),
						i(1),
					}),
				}),
				t(strings.get_space_str(4)),
				-- { 2 } 声明依赖参数输入节点，参数变化时自动重建文档。
				d(4, get_current_func_doc_comment_snip, { 2 }),
				t(strings.get_space_str(4)),
				i(5, "pass"),
			}
		)
	),
}
