-- 运行：nvim --headless "+luafile tests/tooling.lua"
-- 测试导入和自建异步任务；不配置 adapter，也不启动调试会话或监听服务。
local function run()
	local warnings = {}
	local deprecate = vim.deprecate
	vim.deprecate = function(...)
		warnings[#warnings + 1] = { name = tostring((...)), trace = debug.traceback() }
		return deprecate(...)
	end

	require("lazy").load({ plugins = { "nvim-dap-ui", "nvim-nio", "one-small-step-for-vimkind" } })
	local dap = require("dap")
	local adapters = vim.deepcopy(dap.adapters)
	local configurations = vim.deepcopy(dap.configurations)
	local session = dap.session()
	local servers = vim.fn.serverlist()

	-- 导入 config 会填充默认布局，覆盖此前 fill_elements 中的旧 validate 路径。
	local config = require("dapui.config")
	assert(#config.layouts == 2, "DAP UI default layout count changed")
	assert(config.layouts[1].position == "left" and config.layouts[1].size == 40)
	assert(config.layouts[2].position == "bottom" and config.layouts[2].size == 10)
	assert(type(require("dapui").open) == "function", "DAP UI API could not load")

	local nio = require("nio")
	local result
	local wrapped = nio.wrap(function(left, right, callback)
		vim.defer_fn(function()
			callback(left + right)
		end, 1)
	end, 3)
	nio.run(function()
		local value = wrapped(3, 4)
		nio.sleep(1)
		return value
	end, function(ok, value)
		result = { ok = ok, value = value }
	end)
	assert(
		vim.wait(2000, function()
			return result ~= nil
		end, 10),
		"nio.run timed out"
	)
	assert(result.ok and result.value == 7, vim.inspect(result))

	local created_value, created_result
	local created = nio.create(function(value)
		nio.sleep(1)
		created_value = value
	end, 1)
	created(9, function(ok, err)
		created_result = { ok = ok, err = err }
	end)
	assert(
		vim.wait(2000, function()
			return created_result ~= nil
		end, 10),
		"nio.create timed out"
	)
	assert(created_result.ok and created_value == 9, vim.inspect(created_result))

	-- 非法参数必须先被拒绝。额外阻断启动钩子，未来校验回归也不会打开调试服务。
	local osv = require("osv")
	assert(not osv.is_running(), "OSV unexpectedly running before the test")
	local previous_start = osv.on.start_server
	local start_attempted = false
	osv.on.start_server = function()
		start_attempted = true
		error("unexpected attempt to start OSV server")
	end
	for _, case in ipairs({
		{ opts = 42, field = "opts" },
		{ opts = { host = 42 }, field = "opts.host" },
		{ opts = { port = "invalid" }, field = "opts.port" },
	}) do
		local ok, err = pcall(osv.launch, case.opts)
		assert(not ok, "OSV accepted invalid " .. case.field)
		assert(tostring(err):find(case.field, 1, true), tostring(err))
	end
	osv.on.start_server = previous_start
	assert(not start_attempted and not osv.is_running(), "OSV launch passed input validation")
	assert(vim.deep_equal(vim.fn.serverlist(), servers), "test created a listening server")
	assert(vim.deep_equal(dap.adapters, adapters), "test modified DAP adapters")
	assert(vim.deep_equal(dap.configurations, configurations), "test modified DAP launch configurations")
	assert(dap.session() == session, "test started a DAP session")

	for _, warning in ipairs(warnings) do
		for _, plugin in ipairs({ "nvim-dap-ui", "nvim-nio", "one-small-step-for-vimkind" }) do
			assert(not warning.trace:find(plugin, 1, true), warning.name .. "\n" .. warning.trace)
		end
	end
	vim.deprecate = deprecate
	print("TOOLING_OK: DAP UI imports, nio wrap/create/run, OSV validation; no service, session, or deprecations")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd.cquit()
end
vim.cmd.qa({ bang = true })
