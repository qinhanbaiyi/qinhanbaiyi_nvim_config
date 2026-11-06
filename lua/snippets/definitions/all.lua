-- 所有文件类型共用的日期、元信息与示例片段；注释形式取自当前缓冲区的 commentstring。
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
	s({ trig = "data" }, {
		f(function()
			return string.format(string.gsub(vim.bo.commentstring, "%%s", "%%s"), os.date())
		end, {}),
	}),
	s("demo_func", {
		i(1),
		f(function(args, snip, user_arg_1)
			return args[1][1] .. user_arg_1
		end, { 1 }, { user_args = { "Will be appended to text from i(0)" } }),
		i(0),
	}),
	s({ trig = "meta", name = "meta information(include annotation)", dscr = "Title::Author::Date::Description" }, {
		f(function()
			return string.format(string.gsub(vim.bo.commentstring, "%%s", "%%s"), " Title: ")
		end, {}),
		i(1, "Title"),
		t({ "", "" }),
		f(function()
			return string.format(string.gsub(vim.bo.commentstring, "%%s", "%%s"), " Author: ")
		end, {}),
		i(2, "Author"),
		t({ "", "" }),
		f(function()
			return string.format(string.gsub(vim.bo.commentstring, "%%s", "%%s"), " Data: ")
		end, {}),
		f(function()
			return string.format(os.date())
		end, {}),
		t({ "", "" }),
		f(function()
			return string.format(string.gsub(vim.bo.commentstring, "%%s", "%%s"), " Description: ")
		end, {}),
		i(3, "Description"),
	}),
	s({ trig = "meta", name = "meta information(uninclude annotation)", dscr = "Title::Author::Date::Description" }, {
		f(function()
			return string.format("Title: ")
		end, {}),
		i(1, "Title"),
		t({ "", "" }),
		f(function()
			return string.format("Author: ")
		end, {}),
		i(2, "Author"),
		t({ "", "" }),
		f(function()
			return string.format("Data: ")
		end, {}),
		f(function()
			return string.format(os.date())
		end, {}),
		t({ "", "" }),
		f(function()
			return string.format("Description: ")
		end, {}),
		i(3, "Description"),
	}),
}
