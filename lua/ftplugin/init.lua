vim.api.nvim_exec(
	[[
augroup FileTypePlugin
autocmd!
autocmd BufEnter *.md lua require('ftplugin.markdown')

augroup END
]],
	true
)
