local keymap = vim.keymap.set
local opt = { noremap = true, silent = true }
keymap("i", "=", "<-", opt)
keymap("i", "<F10>", "=", opt)
