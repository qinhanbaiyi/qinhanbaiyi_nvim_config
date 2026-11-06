-- Rust 的实例方法与单元测试模板；保留原有触发词、占位符顺序和缩进。
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
	s({ trig = "fn~", name = "fn~ &self", dscr = "** fn name(&self) **" }, {
		t("fn "),
		i(1, "name"),
		t("(&self, "),
		i(2, "param"),
		t(") "),
		c(3, {
			t(""),
			sn(nil, { t(" -> "), i(1) }),
		}),
		t({ " {", "\t" }),
		i(4, ""),
		t({ "\t", "}" }),
	}),
	s("modtest", {
		t({ "#[cfg(test)]", "" }),
		t({ "mod test {" }),
		t({ "", "" }),
		c(1, {
			t({ "    use super::*;" }),
			t({ "" }),
		}),
		t({ "", "" }),
		t("    "),
		i(2),
		t({ "\t", "}" }),
	}),
	s("test", {
		t({ "#[test]", "\t" }),
	}),
}
