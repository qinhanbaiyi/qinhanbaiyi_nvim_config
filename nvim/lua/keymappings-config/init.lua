local keymap = vim.keymap.set
vim.g.mapleader = " "

keymap("n", "<Space>", "<NOP>", { noremap = true, silent = true })
keymap("s", "<c-u>", "<NOP>", { noremap = true, silent = true })
keymap("s", "<c-i>", "<NOP>", { noremap = true, silent = true })

-- W -> :w
keymap("n", "W", ":w<CR>", { noremap = true, silent = true })

-- no highlight
keymap("n", "<Leader>h", ":set hlsearch<CR>", { noremap = true, silent = true })
keymap("n", "<Leader>nh", ":set nohlsearch<CR>", { noremap = true, silent = true })

-- explorer
--vim.api.nvim_set_keymap('n', '<Leader>e', ':Lexplore<CR>', { noremap = true, silent = true})

-- find keys
keymap("n", "/", ":/", { noremap = true, silent = true })

-- Formatter
keymap("n", "<leader>f", ":Format<cr>", { noremap = true, silent = true })

-- use <CR> to creat a new line behind of it.
keymap("n", "<CR>", "o<Esc>", { noremap = true, silent = true })

-- better indenting
keymap("v", "<", "<gv", { noremap = true, silent = true })
keymap("v", ">", ">gv", { noremap = true, silent = true })

--make Y to copy till the end of the line
keymap("n", "Y", "y$", { noremap = true })

--Copy to system clipboarde
-- vim.api.nvim_set_keymap('v', 'Y', '"+y', { noremap = true, })

--Folding
-- vim.api.nvim_set_keymap('n', '<leader>f', 'za', { noremap = true, silent = true})

--Movement
keymap("n", "H", "^", { noremap = true })
keymap("n", "J", "5j", { noremap = true })
keymap("n", "K", "5k", { noremap = true })
keymap("n", "L", "$", { noremap = true })
keymap("i", "<C-l>", "<Right>", { noremap = true, silent = true })
keymap("i", "<C-h>", "<Left>", { noremap = true, silent = true })
keymap("i", "<C-j>", "<Down>", { noremap = true, silent = true })
keymap("i", "<C-k>", "<Up>", { noremap = true, silent = true })
keymap("v", "R", ":SnipRun<CR>", { noremap = true, silent = true })
-- Move selected line / block of text in visual mode

--
--
