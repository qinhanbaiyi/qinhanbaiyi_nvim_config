-- @keymap
local keymap = vim.keymap.set
keymap("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true })
keymap("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
keymap("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
keymap("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
keymap("n", "<leader>b", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
keymap(
	"n",
	"<Leader>B",
	"<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpointcondition:'))<CR>",
	{ noremap = true, silent = true }
)
keymap(
	"n",
	"<Leader>lp",
	"<Cmd>lua require'dap'.set_breakpoint(nil,nil,vim.fn.input('Logpointmessage:'))<CR>",
	{ noremap = true, silent = true }
)
keymap("n", "<Leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", { noremap = true, silent = true })
keymap("n", "<Leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", { noremap = true, silent = true })
