-- 启动入口只负责 leader 与加载顺序，插件选项和快捷键分别放到所属模块。
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 先加载基础行为，再由 Lazy 注册插件；无界面检查遇到启动错误时返回失败。
local ok, err = xpcall(function()
	require("config.options")
	require("config.keymaps")
	require("config.autocmds")
	require("config.lazy")
end, debug.traceback)

if not ok then
	if vim.tbl_contains(vim.v.argv, "--headless") then
		io.stderr:write(err .. "\n")
		vim.cmd.cquit()
	end
	error(err, 0)
end
