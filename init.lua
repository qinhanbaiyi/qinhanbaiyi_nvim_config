-- -- VSCode Neovim
-- vim.cmd({
-- 	if exists('g:vscode')
-- 		" VSCode extension
-- 	else
-- 		" ordinary neovim
-- 	endif
-- })


require('plugins')
require('keymappings-config')
require('nvim_setting-config')
require('nvim-cmp')
require('lsp-settings')

--[[ require('Markdown-preview') ]]
require('texmagic-config')

require('vim-xkbswitch-config')
require('format-config')

require('indent_blankline-config')
require('Treesitter-config')
require('Autopairs-config')
require('Telescope-config')
require('nvim-web-devicons-config')
require('which-key-config')
require('barbar-config')
