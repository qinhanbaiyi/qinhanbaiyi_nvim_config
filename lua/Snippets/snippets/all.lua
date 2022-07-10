local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local types = require("luasnip.util.types")

local all = {}
all = {
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
return all
