vim.api.nvim_exec(
	[[
augroup FileTypePlugin
autocmd!
autocmd BufEnter *.md lua require('ftplugin.markdown')
autocmd BufEnter *.rs lua require('ftplugin.Rust')
autocmd BufEnter *.c lua require('ftplugin.Rust')

augroup END
]],
	true
)
