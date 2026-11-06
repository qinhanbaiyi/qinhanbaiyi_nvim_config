-- 通用编辑事件使用独立 augroup，避免重新加载后重复注册。
-- 文件类型声明与具体 LSP 插件解耦。
vim.filetype.add({ extension = { org = "org" } })

local group = vim.api.nvim_create_augroup("UserEditing", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	desc = "Highlight the yanked text",
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = group,
	pattern = "*.smk",
	desc = "Use four-space indentation in Snakemake files",
	callback = function()
		vim.bo.filetype = "snakemake"
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
		vim.bo.shiftwidth = 4
		vim.bo.expandtab = true
		vim.bo.commentstring = "# %s"
	end,
})
