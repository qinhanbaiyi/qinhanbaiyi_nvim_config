vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set cursorline")
vim.cmd("set hidden")
vim.cmd("set noexpandtab")
vim.cmd("set scrolloff=5")
vim.cmd("set wrap")
vim.cmd("set foldenable")
vim.cmd("set splitright")
vim.cmd("set splitbelow")
vim.cmd("set showcmd")
vim.cmd("set wildmenu")
vim.cmd("set ignorecase")
vim.cmd("set smartcase")
vim.cmd("set colorcolumn=100")
vim.cmd("set updatetime=100")
vim.cmd("set ttyfast")
vim.cmd("set visualbell")

vim.o.mouse = "a"

--Do not save when switching buffers (note: this is now a default on master)
vim.o.hidden = true

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2

-- Highlight on yank
vim.cmd(
	[[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]],
	false
)
