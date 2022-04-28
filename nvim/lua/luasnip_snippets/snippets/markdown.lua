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
local fmt = require("luasnip.extras.fmt").fmt

local markdown = {}
markdown = {
	s("bash", {
		t({ "```bash", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("c", {
		t({ "```c", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("cpp", {
		t({ "```cpp", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("rust", {
		t({ "```rust", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("go", {
		t({ "```go", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("R", {
		t({ "```R", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("url", {
		t("["),
		i(1, "alias"),
		t("]"),
		t("("),
		i(2, "Url_link"),
		t(")"),
		i(0),
	}),
	s({ trig = "image", name = "markdown style", dscr = "markdown style" }, {
		t("!["),
		i(1, "alias"),
		t("]"),
		t("("),
		i(2, "Link or Path"),
		t(")"),
		i(0),
	}),
	s({ trig = "image", name = "html style", dscr = "html style" }, {
		t({ '<img src="' }),
		i(1, "Path or Url"),
		t({ '" alt="' }),
		i(2, "alias"),
		t('"'),
		c(3, {
			t(""),
			sn(1, {
				t(" width="),
				i(1, "number"),
				t(" height="),
				i(2, "number"),
			}),
		}),
		t(">"),
	}),
	s({ trig = "tb(%d+)*(%d+)", regTrig = true, dscr = "生成表格" }, {
		-- pos, function, argnodes, user_arg1
		d(1, function(args, snip, old_state, initial_text)
			local nodes = {}
			-- count is nil for invalid input.
			local row = snip.captures[1]
			local col = snip.captures[2]
			-- Make sure there's a number in args[1] and arg[2].
			for j = 1, row + 1 do
				for k = 1, col do
					local iNode
					if j == 2 then
						iNode = i((j - 1) * col + k, ":-:")
					else
						iNode = i((j - 1) * col + k, initial_text)
					end
					nodes[(col * 2 + 1) * (j - 1) + 2 * k] = iNode
					nodes[(col * 2 + 1) * (j - 1) + 2 * k - 1] = t("|")
				end
				-- linebreak
				nodes[(col * 2 + 1) * (j - 1) + 2 * col + 1] = t({ "|", "" })
			end
			local snip = sn(nil, nodes)
			-- snip.old_state = old_state
			return snip
		end, {}, "   "),
	}),
}
return markdown
