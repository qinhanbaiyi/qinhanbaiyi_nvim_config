local keymap = vim.api.nvim_set_keymap

keymap("v", "<LEADER>h1", "I# <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h2", "I## <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h3", "I### <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h4", "I#### <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h5", "I##### <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h6", "I###### <ESC>", { noremap = true, silent = true })
