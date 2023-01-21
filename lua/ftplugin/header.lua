local header = function()
	print("Add header information")
end
vim.api.nvim_create_autocmd({ "BufNewFile" }, {
	pattern = { "*.py", "*.pyi" },
	callback = header,
})
