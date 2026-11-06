-- 在已安装插件的配置中运行：nvim --headless "+luafile tests/snippets.lua"
-- 测试只创建未命名缓冲区，不保存或改写用户文件；隔离环境请由调用方设置 XDG_*。
local function run()
	local deprecated = {}
	local original_deprecate = vim.deprecate
	vim.deprecate = function(...)
		-- 保留原始提示，只记录调用来源，确保测试没有靠静音掩盖弃用问题。
		deprecated[#deprecated + 1] = { name = tostring((...)), trace = debug.traceback() }
		return original_deprecate(...)
	end

	require("lazy").load({ plugins = { "LuaSnip" } })
	local ls = require("luasnip")
	assert(require("luasnip.util.jsregexp"), "LuaSnip jsregexp build is missing")
	local counts = { all = 4, r = 7, tex = 10, python = 1, rust = 3, lua = 4, go = 2, markdown = 13 }
	local function assert_counts()
		for ft, expected in pairs(counts) do
			assert(#ls.get_snippets(ft) == expected, ft .. " snippet count changed")
		end
	end
	assert_counts()

	local helper_before = require("snippets.helpers.lua")
	local reload = vim.fn.maparg("<leader><leader>s", "n", false, true).callback
	assert(type(reload) == "function", "snippet reload key is missing")
	reload()
	assert_counts()
	assert(require("snippets.helpers.lua") ~= helper_before, "helper cache was not refreshed")
	reload()
	assert_counts()

	local function text()
		return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	end
	local function contains(fragment)
		assert(text():find(fragment, 1, true), "missing " .. fragment .. " in:\n" .. text())
	end
	local function expand(ft, trigger, expand_params)
		vim.cmd.enew({ bang = true })
		vim.bo.filetype = ft
		local target
		for _, snippet in ipairs(ls.get_snippets(ft)) do
			if snippet.trigger == trigger then
				target = snippet
				break
			end
		end
		assert(target, "missing snippet " .. ft .. "/" .. trigger)
		ls.snip_expand(target, { expand_params = expand_params })
	end
	local function current()
		return assert(ls.session.current_nodes[vim.api.nvim_get_current_buf()], "no active snippet node")
	end
	local function edit(value)
		-- 向当前占位符写入测试文本，后续更新走 LuaSnip 的公开 API。
		local node = current()
		local pos = node.mark:pos_begin_end_raw()
		vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
		node:set_text({ value })
		ls.active_update_dependents()
	end
	local function key(lhs, mode)
		local mapping = vim.fn.maparg(lhs, mode or "i", false, true)
		assert(type(mapping.callback) == "function", "missing callback for " .. lhs)
		mapping.callback()
	end

	expand("lua", "func")
	edit("sum")
	key("<C-k>")
	assert(current().pos == 2, "C-k did not move to Lua parameters")
	edit("first, second")
	contains("function sum(first, second)")
	contains("-- @param { any } first")
	contains("-- @param { any } second")
	key("<C-j>")
	assert(current().pos == 1, "C-j did not return to the function name")
	key("<C-k>", "s")
	assert(current().pos == 2, "select-mode C-k did not advance")
	key("<C-k>")
	assert(current().pos == 3, "C-k did not move to the Lua body")

	expand("r", "func")
	edit("sum")
	key("<C-k>")
	edit("first, second = 2")
	contains("#' @param first")
	contains("#' @param second")
	-- 参数说明包含自己的插入节点，按 C-k 跳过它们后再到函数体。
	for _ = 1, 10 do
		local node = current()
		if node.pos == 4 and node.parent.trigger == "func" then
			break
		end
		key("<C-k>")
	end
	assert(current().pos == 4, "did not reach R function body")
	edit("return(first + second)")
	contains("#' @return (first + second)")
	contains("sum <- function(first, second = 2)")

	expand("lua", "req")
	edit("snippets.helpers.string")
	assert(text() == "local string = require('snippets.helpers.string')", text())
	key("<C-k>")
	key("<C-j>")
	assert(current().pos == 1, "snippet history no longer allows jumping back")
	edit("snippets.helpers.lua")
	contains("local lua = require('snippets.helpers.lua')")

	expand("python", "func")
	key("<C-k>")
	edit("first, second")
	contains("@param: first")
	contains("@param: second")
	key("<C-k>")
	assert(ls.choice_active(), "Python return type choice is inactive")
	key("<C-l>")
	contains("-> ")

	expand("markdown", "tb(%d+)*(%d+)", { trigger = "tb2*3", captures = { "2", "3" } })
	contains("|:-:|:-:|:-:|")

	-- 调用会经过 LuaSnip 的 filetype 去重路径，旧版在这里使用弃用的 vim.validate({ ... })。
	ls.expandable()
	local post = require("luasnip.extras.postfix").postfix
	assert(post(".test", { ls.text_node("tested") }), "postfix validation failed")

	local cfg = require("luasnip.session").config
	assert(cfg.keep_roots and cfg.link_roots and cfg.link_children and not cfg.exit_roots)
	assert(vim.deep_equal(cfg.update_events, { "TextChanged", "TextChangedI" }))
	for _, warning in ipairs(deprecated) do
		assert(not warning.trace:find("LuaSnip", 1, true), warning.name .. "\n" .. warning.trace)
	end
	vim.deprecate = original_deprecate
	print(
		"SNIPPETS_OK: 44 definitions, dynamic Lua/R/Python, jumps, choices, history, reload, regex, no LuaSnip deprecations"
	)
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd.cquit()
end
vim.cmd.qa({ bang = true })
