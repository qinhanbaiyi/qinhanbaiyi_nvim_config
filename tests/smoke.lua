-- 面向重构的运行时回归检查，不连接外部 AI，也不改写用户文件。
local function check()
	local root = assert(vim.env.NVIM_CONFIG_TEST_ROOT)
	assert(
		vim.uv.fs_realpath(vim.fn.stdpath("config")) == vim.uv.fs_realpath(root),
		"请在已安装的配置目录运行检查"
	)

	require("lazy").load({
		plugins = {
			"which-key.nvim",
			"LuaSnip",
			"blink.cmp",
			"nvim-lspconfig",
			"lspsaga.nvim",
			"conform.nvim",
			"telescope.nvim",
			"glow.nvim",
			"neogen",
			"neo-tree.nvim",
			"barbar.nvim",
			"indent-blankline.nvim",
		},
	})
	for path, kind in vim.fs.dir(root .. "/lua", { depth = math.huge }) do
		if kind == "file" and path:sub(-4) == ".lua" then
			assert(loadfile(root .. "/lua/" .. path))
		end
	end

	-- Lazy 的插件清单、锁文件与磁盘 checkout 必须一致，避免漏迁移或误升级。
	local plugins = require("lazy.core.config").plugins
	local lock = vim.json.decode(table.concat(vim.fn.readfile(root .. "/lazy-lock.json"), "\n"))
	local count = 0
	for name, plugin in pairs(plugins) do
		assert(lock[name], "插件没有锁定版本 " .. name)
		local result = vim.system({ "git", "-C", plugin.dir, "rev-parse", "HEAD" }, { text = true }):wait()
		assert(
			result.code == 0 and vim.trim(result.stdout) == lock[name].commit,
			"插件版本与锁文件不符 " .. name
		)
		count = count + 1
	end
	for name in pairs(lock) do
		assert(plugins[name], "锁文件遗留了已移除的插件 " .. name)
	end
	assert(not plugins["neodev.nvim"] and plugins["lazydev.nvim"], "Lua 开发插件未完成迁移")

	local function mapping(mode, lhs, rhs)
		local actual = vim.fn.maparg(lhs, mode, false, true)
		assert(next(actual), "缺失快捷键 " .. mode .. " " .. lhs)
		if rhs then
			assert(vim.keycode(actual.rhs or "") == vim.keycode(rhs), "快捷键行为改变 " .. mode .. " " .. lhs)
		end
		return actual
	end
	for lhs, rhs in pairs({ H = "^", J = "5j", K = "5k", L = "$", ["<CR>"] = "o<Esc>" }) do
		mapping("n", lhs, rhs)
	end
	assert(vim.fn.maparg("n", "n") == "", "不应覆盖原生搜索下一项 n")
	for _, mode in ipairs({ "n", "x", "s" }) do
		mapping(mode, "gd", "<cmd>Lspsaga peek_definition<CR>")
		assert(mapping(mode, "gr", "<cmd>Lspsaga finder ref<CR>").nowait == 1)
		assert(mapping(mode, "gh", "<cmd>Lspsaga hover_doc<CR>").silent == 1)
		mapping(mode, "<leader>ff", "<cmd>Telescope find_files<cr>")
		mapping(mode, "<leader>e", "<cmd>Neotree toggle<cr>")
		mapping(mode, "<leader><leader>j", "<c-w>j")
	end
	mapping("n", "<leader>f", ":Format<cr>")
	mapping("n", "<leader>cf", "<cmd>lua vim.lsp.buf.format {async = true}<CR>")
	for _, mode in ipairs({ "i", "s" }) do
		for _, lhs in ipairs({ "<C-k>", "<C-j>", "<C-l>" }) do
			assert(type(mapping(mode, lhs).callback) == "function")
		end
	end

	local ls = require("luasnip")
	local function snippet_counts()
		local counts = {}
		for _, ft in ipairs({ "all", "lua", "r", "go", "rust", "tex", "python", "markdown" }) do
			counts[ft] = #ls.get_snippets(ft)
			assert(counts[ft] > 0, "片段模块未加载 " .. ft)
		end
		return counts
	end
	local before = snippet_counts()
	require("snippets").reload()
	require("snippets").reload()
	assert(vim.deep_equal(before, snippet_counts()), "重载产生了丢失或重复的片段")
	assert(vim.g.colors_name == "onedark")
	assert(vim.filetype.match({ filename = "example.org" }) == "org")
	assert(vim.fn.exists(":Format") == 2 and vim.fn.exists(":Prettier") == 2)
	assert(vim.fn.exists(":SymbolsOutline") == 2, "旧大纲命令未保留")
	print(("PASS: %d 个插件版本、键位、主题、片段重载和命令检查"):format(count))
end

vim.defer_fn(function()
	local ok, err = xpcall(check, debug.traceback)
	if not ok then
		io.stderr:write(err .. "\n")
		vim.cmd.cquit()
	end
	vim.cmd.qa({ bang = true })
end, 700)
