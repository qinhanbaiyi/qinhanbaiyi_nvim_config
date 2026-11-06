-- R 函数文档与常用操作符片段。参数和返回值标签由 helpers/r.lua 读取语法树生成。
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local r_utils = require("snippets.helpers.r")
local su = require("snippets.helpers.string")
local tl = su.box_trim_lines
local indentation = su.get_space_str(8)

return {
	s(
		"func",
		fmt(
			tl([[
			{}{}{}
			{} <- function({}) {{
			{}{}
			}}
			]]),
			{
				f(function(args)
					return "#' @description " .. args[1][1]
				end, { 1 }),
				-- 参数节点 2 与函数体节点 4 分别驱动参数和返回值文档。
				d(3, r_utils.get_current_func_doc_comment_snip, { 2 }),
				d(5, r_utils.get_current_func_return_snip, { 4 }),
				i(1),
				i(2),
				t(indentation),
				i(4),
			}
		)
	),
	s("pp", {
		t({ "%>%", "" }),
		t({ "" }),
	}),
	s("in", {
		t("%in% "),
	}),
	s("lp", {
		t("%<>% "),
	}),
	s("tp", {
		t("%T>% "),
	}),
	s("e", {
		t("<- "),
	}),
	s({ trig = "param" }, {
		t({ "@param", "" }),
		t({ "@param", "" }),
	}, {
		condition = function(line)
			if line:match("#") then
				return true
			end
			return false
		end,
	}),
}
