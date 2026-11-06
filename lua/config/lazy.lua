-- 固定 Lazy 引导版本，插件清单统一从 plugins/ 导入，具体提交由锁文件记录。
local version = "v11.17.1"
local data = vim.fn.stdpath("data")
local lazypath = vim.fs.joinpath(data, "lazy", "lazy.nvim")
local entry = vim.fs.joinpath(lazypath, "lua", "lazy", "init.lua")

if not vim.uv.fs_stat(entry) then
	if vim.fn.executable("git") == 0 then
		error("Git is required to install lazy.nvim", 0)
	end

	vim.fn.mkdir(vim.fs.dirname(lazypath), "p")
	local staging = assert(vim.uv.fs_mkdtemp(vim.fs.joinpath(data, "lazy-bootstrap-XXXXXX")))
	local output = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--depth=1",
		"--branch",
		version,
		"https://github.com/folke/lazy.nvim.git",
		staging,
	})
	if vim.v.shell_error ~= 0 then
		vim.fn.delete(staging, "rf")
		error("Failed to install lazy.nvim " .. version .. "\n" .. output, 0)
	end

	-- 克隆完成后才原子替换目录，避免并发启动读到未完成的插件。
	local installed, rename_error = vim.uv.fs_rename(staging, lazypath)
	if not installed then
		vim.fn.delete(staging, "rf")
		if not vim.uv.fs_stat(entry) then
			error("Cannot install lazy.nvim at " .. lazypath .. "\n" .. rename_error, 0)
		end
	end
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	spec = {
		{ "folke/lazy.nvim", version = version },
		{ import = "plugins" },
	},
	install = { colorscheme = { "habamax" } },
	checker = { enabled = false },
})
