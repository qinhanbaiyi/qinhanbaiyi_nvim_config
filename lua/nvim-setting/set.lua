vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set cursorline")
vim.cmd("set noexpandtab")
vim.cmd("set scrolloff=5")
vim.cmd("set wrap")
vim.cmd("set foldenable")
vim.cmd("set colorcolumn=100")
vim.o.mouse = "a"
vim.o.showcmd = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.ignorecase = true
vim.o.wildmenu = true
vim.o.smartcase = true
vim.o.updatetime = 100
vim.o.ttyfast = true
vim.o.visualbell = true
--Do not save when switching buffers (note: this is now a default on master)
vim.o.hidden = true
--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})
