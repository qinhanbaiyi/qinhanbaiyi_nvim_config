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
}
return markdown
