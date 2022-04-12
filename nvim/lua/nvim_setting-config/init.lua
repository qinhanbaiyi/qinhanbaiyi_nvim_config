vim.api.nvim_command('set number')
vim.api.nvim_command('set relativenumber')
vim.api.nvim_command('set cursorline')
vim.api.nvim_command('set hidden')
vim.api.nvim_command('set noexpandtab')
vim.api.nvim_command('set scrolloff=5')
vim.api.nvim_command('set wrap')
vim.api.nvim_command('set foldenable')
vim.api.nvim_command('set splitright')
vim.api.nvim_command('set splitbelow')
vim.api.nvim_command('set showcmd')
vim.api.nvim_command('set wildmenu')
vim.api.nvim_command('set ignorecase')
vim.api.nvim_command('set smartcase')
vim.api.nvim_command('set colorcolumn=100')
vim.api.nvim_command('set updatetime=100')
vim.api.nvim_command('set ttyfast')
vim.api.nvim_command('set visualbell')
vim.api.nvim_command('')
vim.api.nvim_command('')

vim.o.mouse = 'a'

--Do not save when switching buffers (note: this is now a default on master)
vim.o.hidden = true



--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
vim.cmd [[colorscheme onedark]]

--Set statusbar
vim.g.lightline = {
  colorscheme = 'onedark',
  active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } },
  component_function = { gitbranch = 'fugitive#head' },
}



-- Highlight on yank
vim.api.nvim_exec(
  [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]],
  false
)






















