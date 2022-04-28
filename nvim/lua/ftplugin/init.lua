vim.api.nvim_exec(
	[[
augroup FileTypePlugin
autocmd!
autocmd BufEnter *.md lua require('ftplugin.markdown')
autocmd BufEnter *.rs lua require('ftplugin.Rust')
autocmd BufEnter *.c lua require('ftplugin.c')
autocmd BufEnter *.r lua require('ftplugin.R')
autocmd BufEnter *.tex,*.bib lua require('ftplugin.latex')

augroup END
]],
	true
)

local M = {
	"ftplugin.header",
}
for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error in calling autocmd of header", err)
	end
end
