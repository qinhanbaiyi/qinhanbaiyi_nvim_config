vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', { noremap = true, silent = true})
vim.g.mapleader = ' '

-- no highlight
vim.api.nvim_set_keymap('n', '<Leader>h', ':set hlsearch<CR>', { noremap = true, silent = true})

-- explorer
--vim.api.nvim_set_keymap('n', '<Leader>e', ':Lexplore<CR>', { noremap = true, silent = true})

-- NvimTree
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true})

-- use <CR> to creat a new line behind of it. 
vim.api.nvim_set_keymap('n', '<CR>', 'o<ESC>', { noremap = true, silent = true})

-- better window movement
vim.api.nvim_set_keymap('n', '<Leader><Leader>h', '<c-w>h', { silent = true})
vim.api.nvim_set_keymap('n', '<Leader><Leader>j', '<c-w>j', { silent = true})
vim.api.nvim_set_keymap('n', '<Leader><Leader>k', '<c-w>k', { silent = true})
vim.api.nvim_set_keymap('n', '<Leader><Leader>l', '<c-w>l', { silent = true})

-- better indenting
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true})

--make Y to copy till the end of the line
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true, })

--Copy to system clipboarde
vim.api.nvim_set_keymap('v', 'Y', '"+y', { noremap = true, })

--Folding
vim.api.nvim_set_keymap('n', '<leader>f', 'za', { noremap = true, silent = true})

--Movement
vim.api.nvim_set_keymap('n', 'H', '5h', { noremap = true })
vim.api.nvim_set_keymap('n', 'J', '5j', { noremap = true })
vim.api.nvim_set_keymap('n', 'K', '5k', { noremap = true })
vim.api.nvim_set_keymap('n', 'L', '5l', { noremap = true })

-- Move selected line / block of text in visual mode
vim.api.nvim_set_keymap('x', 'K', ':move \'<-2<CR>gv-gv\'', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'J', ':move \'>+1<CR>gv-gv\'', { noremap = true, silent = true })

--
--

