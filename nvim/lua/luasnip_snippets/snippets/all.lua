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
	s("paren_change", {
		c(1, {
			sn(1, { t("("), r(1, "user_text"), t(")") }),
			sn(2, { t("["), r(1, "user_text"), t("]") }),
			sn(3, { t("{"), r(1, "user_text"), t("}") }),
		}),
	}, {
		stored = {
			user_text = i(1, "default_text"),
		},
	}),
}
return all
