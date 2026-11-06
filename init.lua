vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local ok, err = xpcall(function()
	require("config.options")
	require("config.keymaps")
	require("config.autocmds")
	require("config.lazy")
	require("config.which")
end, debug.traceback)

if not ok then
	if vim.tbl_contains(vim.v.argv, "--headless") then
		io.stderr:write(err .. "\n")
		vim.cmd.cquit()
	end
	error(err, 0)
end
