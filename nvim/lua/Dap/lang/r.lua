local dap = require("dap")
dap.adapters.r = {
	type = "executable",
	command = "/usr/bin/R",
	args = { '-f ~/demo.r"' },
}
-- dap.configurations.r = {
-- 	{
-- 		-- The first three options are required by nvim-dap
-- 		type = "r", -- the type here established the link to the adapter definition: `dap.adapters.python`
-- 		request = "launch",
-- 		name = "Launch Workspace",
-- 		debugMode = "Workspace",
-- 		workingDirectory = "${workspaceFolder}",
-- 		allowGlobalDebugging = true,
--
-- 		-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
--
-- 		-- program = "${file}", -- This configuration will launch the current file if used.
-- 		-- pythonPath = function()
-- 		-- 	-- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
-- 		-- 	-- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
-- 		-- 	-- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
-- 		-- 	local cwd = vim.fn.getcwd()
-- 		-- 	if vim.fn.executable("/home/baiyi/python/virtualenvs/debugpy/bin/python3") == 1 then
-- 		-- 		return "/home/baiyi/python/virtualenvs/debugpy/bin/python3"
-- 		-- 	elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
-- 		-- 		return cwd .. "/.venv/bin/python"
-- 		-- 	else
-- 		-- 		return "/usr/bin/python3"
-- 		-- 	end
-- 		-- end,
-- 	},
-- }
dap.configurations.r = {
	{
		type = "r",
		program = "~/.vscode-server/extensions/rdebugger.r-debugger-0.4.7/out/debugAdapter.js",
		request = "launch",
		name = "Launch Workspace",
		debugMode = "Workspace",
		workingDirectory = "${workspaceFolder}",
		allowGlobalDebugging = true,
	},
}
