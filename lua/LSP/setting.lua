-- LSP UI
vim.diagnostic.config({
	virtual_text = {
		prefix = "<<<", -- Could be '●', '▎', 'x'
	},
	signs = true,
	underline = false,
	update_in_insert = false,
	severity_sort = false,
})

local signs = { Error = ">", Warn = ">", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
