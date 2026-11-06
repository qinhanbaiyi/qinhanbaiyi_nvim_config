local map = vim.keymap.set

map("n", "<Space>", "<Nop>", { silent = true })
map("s", "<C-u>", "<Nop>", { silent = true })
map("s", "<C-i>", "<Nop>", { silent = true })
map({ "n", "x", "i", "s" }, "<C-s>", "<cmd>w<CR>", { desc = "Save File", silent = true })
map("n", "<leader>h", ":set hlsearch<CR>", { desc = "Enable Search Highlighting", silent = true })
map("n", "<leader>nh", ":set nohlsearch<CR>", { desc = "Disable Search Highlighting", silent = true })
map("n", "/", ":/", { silent = true })
map("n", "<leader>f", ":Format<cr>", { desc = "Format File", silent = true })

-- Keep the editing motions and reselect after visual indentation.
map("n", "<CR>", "o<Esc>", { desc = "Open Line Below", silent = true })
map("v", "<", "<gv", { silent = true })
map("v", ">", ">gv", { silent = true })
map("n", "Y", "y$", { desc = "Yank to End of Line", silent = true })
map("n", "H", "^", { silent = true })
map("n", "J", "5j", { silent = true })
map("n", "K", "5k", { silent = true })
map("n", "L", "$", { silent = true })
map("i", "<C-h>", "<Left>", { silent = true })
map("i", "<C-j>", "<Down>", { silent = true })
map("i", "<C-k>", "<Up>", { silent = true })
map("i", "<C-l>", "<Right>", { silent = true })
