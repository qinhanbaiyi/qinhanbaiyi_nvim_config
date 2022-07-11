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
local fmt = require("luasnip.extras.fmt").fmt
local m = require("luasnip.extras").m
local lambda = require("luasnip.extras").l
local postfix = require("luasnip.extras.postfix").postfix

local M = {}

-- parse_syntax_tree parse the syntax for the current changes
function Utils.refresh_syntax_tree()
	local language_tree = vim.treesitter.get_parser(0, "lua")
	language_tree:parse()
end

function M:get_current_func_doc_comment_snip(args, snip)
	local snip_nodes = {}

end

return M
