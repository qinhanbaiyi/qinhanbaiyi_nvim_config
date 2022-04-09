local keymap = vim.api.nvim_set_keymap

keymap("n", "<LEADER>h1", "I# <ESC>", { noremap = true, silent = true })
keymap("n", "<LEADER>h2", "I## <ESC>", { noremap = true, silent = true })
keymap("n", "<LEADER>h3", "I### <ESC>", { noremap = true, silent = true })
keymap("n", "<LEADER>h4", "I#### <ESC>", { noremap = true, silent = true })
keymap("n", "<LEADER>h5", "I##### <ESC>", { noremap = true, silent = true })
keymap("n", "<LEADER>h6", "I###### <ESC>", { noremap = true, silent = true })

keymap("n", "<LEADER>mu", "i[]()<Left><Left><Left>", { noremap = true, silent = true })
keymap("n", "<LEADER>mi", 'i<img src=""><Left><Left>', { noremap = true, silent = true })
