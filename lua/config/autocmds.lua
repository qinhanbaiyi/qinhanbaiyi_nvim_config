-- 1. Snakemake

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.smk" },
	callback = function()
		vim.bo.filetype = "snakemake"
		vim.bo.ts = 4
		vim.bo.sts = 4
		vim.bo.shiftwidth = 4
		vim.bo.expandtab = true
		vim.bo.commentstring = "# %s"
	end,
})
