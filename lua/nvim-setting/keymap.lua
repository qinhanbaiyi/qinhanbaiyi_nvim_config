local keymap = vim.keymap.set
vim.g.mapleader = " "

local opts = { noremap = true, silent = true }

keymap("n", "<Space>", "<NOP>", opts)
keymap("s", "<c-u>", "<NOP>", opts)
keymap("s", "<c-i>", "<NOP>", opts)

-- W -> :w
keymap("n", "W", ":w<CR>", opts)

-- no highlight
keymap("n", "<Leader>h", ":set hlsearch<CR>", opts)
keymap("n", "<Leader>nh", ":set nohlsearch<CR>", opts)

-- explorer
--vim.api.nvim_set_keymap('n', '<Leader>e', ':Lexplore<CR>', opts)

-- find keys
keymap("n", "/", ":/", opts)

-- Formatter
keymap("n", "<leader>f", ":Format<cr>", opts)

-- use <CR> to creat a new line behind of it.
keymap("n", "<CR>", "o<Esc>", opts)

-- better indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

--make Y to copy till the end of the line
keymap("n", "Y", "y$", opts)

--Copy to system clipboarde
-- vim.api.nvim_set_keymap('v', 'Y', '"+y', opts)

--Folding
-- vim.api.nvim_set_keymap('n', '<leader>f', 'za', opts)

--Movement
keymap("n", "H", "^", opts)
keymap("n", "J", "5j", opts)
keymap("n", "K", "5k", opts)
keymap("n", "L", "$", opts)
keymap("i", "<C-l>", "<Right>", opts)
keymap("i", "<C-h>", "<Left>", opts)
keymap("i", "<C-j>", "<Down>", opts)
keymap("i", "<C-k>", "<Up>", opts)
keymap("v", "R", ":SnipRun<CR>", opts)
-- Move selected line / block of text in visual mode

--
--
