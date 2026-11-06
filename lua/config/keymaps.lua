-- 不依赖插件的全局快捷键。插件操作由各自的 keys 字段注册。
local map = vim.keymap.set

-- Leader 先占位，避免等待后执行空格默认移动；Ctrl-S 在四种模式共用保存入口。
map("n", "<Space>", "<Nop>", { silent = true })
map("s", "<C-u>", "<Nop>", { silent = true })
map("s", "<C-i>", "<Nop>", { silent = true })
map({ "n", "x", "i", "s" }, "<C-s>", "<cmd>w<CR>", { desc = "Save File", silent = true })
map("n", "<leader>h", ":set hlsearch<CR>", { desc = "Enable Search Highlighting", silent = true })
map("n", "<leader>nh", ":set nohlsearch<CR>", { desc = "Disable Search Highlighting", silent = true })
map("n", "/", ":/", { silent = true })

-- 保留 H/J/K/L 移动习惯，可视模式缩进后继续保持选区。
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

-- 窗口、移行和 Quickfix 属于编辑器本身，不依赖插件。
-- 表中的 mode/remap 属于真实映射选项，Which-key 只读取 desc 生成提示。
for _, entry in ipairs({
	{ "[q", "<cmd>cprev<CR>", desc = "Previous Quickfix", mode = "n", silent = true },
	{ "]q", "<cmd>cnext<CR>", desc = "Next Quickfix", mode = "n", silent = true },
	{ "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", mode = "n", desc = "Move Down", silent = true },
	{ "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", mode = "n", desc = "Move Up", silent = true },
	{ "<A-j>", "<esc><cmd>m .+1<cr>==gi", mode = "i", desc = "Move Down", silent = true },
	{ "<A-k>", "<esc><cmd>m .-2<cr>==gi", mode = "i", desc = "Move Up", silent = true },
	{ "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", mode = "v", desc = "Move Down", silent = true },
	{
		"<A-k>",
		":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
		mode = "v",
		desc = "Move Up",
		silent = true,
	},
	{ "<leader>ui", vim.show_pos, mode = "n", desc = "Inspect Pos", silent = true },
	{ "<leader>uI", "<cmd>InspectTree<cr>", mode = "n", desc = "Inspect Tree", silent = true },
	{ "<leader><leader>h", "<c-w>h", desc = "Left", remap = false, mode = { "n", "v" }, silent = true },
	{ "<leader><leader>j", "<c-w>j", desc = "Down", remap = false, mode = { "n", "v" }, silent = true },
	{ "<leader><leader>k", "<c-w>k", desc = "Up", remap = false, mode = { "n", "v" }, silent = true },
	{ "<leader><leader>l", "<c-w>l", desc = "Right", remap = false, mode = { "n", "v" }, silent = true },
	{ "<leader><leader>-", "<C-W>s", mode = "n", desc = "Split Window Below", remap = true, silent = true },
	{ "<leader><leader>|", "<C-W>v", mode = "n", desc = "Split Window Right", remap = true, silent = true },
	{ "<leader><leader>wd", "<C-W>c", mode = "n", desc = "Delete Window", remap = true, silent = true },
}) do
	local mode, lhs, rhs = entry.mode, entry[1], entry[2]
	entry.mode, entry[1], entry[2] = nil, nil, nil
	map(mode, lhs, rhs, entry)
end
