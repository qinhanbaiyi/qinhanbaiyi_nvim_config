local keymap = vim.api.nvim_set_keymap

keymap("v", "<LEADER>h1", "I# <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h2", "I## <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h3", "I### <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h4", "I#### <ESC>", { noremap = true, silent = true })
keymap("v", "<LEADER>h5", "I##### <ESC>", { noremap = true, silent = true })

-- markdown preview Glow
vim.g.glow_border = "rounded"
-- dark or light module
vim.g.glow_style = "dark"
vim.g.glow_use_pager = false
vim.g.glow_width = 160
keymap("v", "<LEADER>h6", "I###### <ESC>", { noremap = true, silent = true })
