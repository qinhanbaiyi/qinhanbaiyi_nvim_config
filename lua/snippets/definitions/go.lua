-- Go 赋值片段；模块只返回 LuaSnip 定义，统一注册由 snippets/init.lua 完成。
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s({ trig = "let" }, {
		i(1),
		t(" := "),
		i(2),
	}),
	s({ trig = "e" }, {
		t(":= "),
	}),
}
