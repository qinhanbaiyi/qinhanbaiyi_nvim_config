-- 自定义片段的唯一注册入口，由插件加载时调用 load()，由 <leader><leader>s 调用 reload()。
local M = {}

-- 添加语言时，在 definitions/ 新建返回片段数组的同名模块，并在这里登记 filetype。
-- all 是 LuaSnip 的共享类别，会参与各语言的补全。片段模块只返回定义，不自行注册。
local filetypes = { "all", "r", "lua", "tex", "python", "rust", "markdown", "go" }

function M.load()
	local definitions = {}
	-- 所有模块成功加载后再注册，避免语法错误导致只替换了一部分片段。
	for _, filetype in ipairs(filetypes) do
		definitions[filetype] = require("snippets.definitions." .. filetype)
	end
	local ls = require("luasnip")
	for _, filetype in ipairs(filetypes) do
		-- 稳定的 key 让重载替换旧定义，不累积重复候选。
		ls.add_snippets(filetype, definitions[filetype], { key = filetype })
	end
end

function M.reload()
	-- 同时刷新语言定义、辅助函数与本模块，新增语言后也能直接重载。
	-- 只清理自有 snippets 命名空间，LuaSnip 引擎与其它插件的模块缓存保持有效。
	for module in pairs(package.loaded) do
		if type(module) == "string" and (module == "snippets" or vim.startswith(module, "snippets.")) then
			package.loaded[module] = nil
		end
	end
	-- 新模块存在语法/加载错误时报告错误，之前已注册的片段仍可继续使用。
	local ok, err = pcall(function()
		require("snippets").load()
	end)
	if ok then
		require("luasnip").clean_invalidated()
		vim.notify("LuaSnip snippets reloaded")
	else
		vim.notify(err, vim.log.levels.ERROR)
	end
end

return M
