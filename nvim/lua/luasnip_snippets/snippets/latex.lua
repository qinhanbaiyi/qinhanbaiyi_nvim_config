local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local rec_ls
rec_ls = function()
	return sn(nil, {
		c(1, {
			-- important!! Having the sn(...) as the first choice will cause infinite recursion.
			t({ "" }),
			-- The same dynamicNode as in the snippet (also note: self reference).
			sn(nil, {
				t({ "", "\t\\item " }),
				i(1),
				d(2, rec_ls, {}),
			}),
		}),
	})
end

local M = {}
M = {
	s("itemize", {
		t({ "\\begin{itemize}", "\t\\item " }),
		i(1),
		d(2, rec_ls, {}),
		t({ "", "\\end{itemize}" }),
		i(0),
	}),
	s("enum", {
		t({ "\\begin{enumerate}", "\t\\item " }),
		i(1),
		d(2, rec_ls, {}),
		t({ "", "\\end{enumerate}" }),
		i(0),
	}),
	s("par", {
		t({ "\\paragraph{" }),
		i(1),
		t({ "}", "" }),
		i(2),
		t({ "", "\\par" }),
		i(0),
	}),
}

return M
