----------------------------------------------------------------------
---------------------------- Setup -----------------------------------
----------------------------------------------------------------------
local wk = require("which-key")
--[[ local opts = {
	mode = "n", -- NORMAL mode
	-- prefix: use "<leader>f" for example for mapping everything related to finding files
	-- the prefix is prepended to every mapping part of `mappings`
	prefix = "",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = false, -- use `nowait` when creating keymaps
} ]]

-- diagnostic
local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end

-- sniprun treesitter node select for executing
local treesitter_node_select = function()
	local ts_utils = require("nvim-treesitter.ts_utils")
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_node = ts_utils.get_node_at_cursor()

	local exp_state_node

	-- while ts_utils.is_parent(cursor_node) do
	while
		string.find(cursor_node:type(), "statement") == nil
		-- cursor_node:type() ~= "expression_statement"
		and cursor_node:parent() ~= nil
		and cursor_node:type() ~= "function_definition"
	do
		-- cursor_node = ts_utils.get_previous_node(cursor_node)
		cursor_node = cursor_node:parent()
	end

	ts_utils.update_selection(bufnr, cursor_node)

	-- for _, node in ipairs(scope) do
	-- 	if node:type() == "expression_statement" then
	-- 		exp_state_node = node
	-- 		break
	-- 	end
	-- end
	-- print(exp_state_node)
	-- ts_utils.update_selection(bufnr, exp_state_node)
end

-- sniprun
local execute_sniprun = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local total_lines = vim.api.nvim_buf_line_count(bufnr)
	local linenr = vim.api.nvim_win_get_cursor(0)[1]
	if linenr == total_lines then
		vim.api.nvim_win_set_cursor(0, { linenr, 0 })
	else
		vim.api.nvim_win_set_cursor(0, { linenr + 1, 9999 })
	end
end

wk.add({
	---@group [ and ] for buffer navigation
	-- Prev
	{ "[", group = "prev" },
	{ "[b", "<cmd>BufferPrevious<CR>", mode = "n", desc = "Previous Buffer" },
	{ "[q", "<cmd>cprev<CR>", desc = "Previous Quickfix", mode = "n" },
	{ "[d", "<cmd>Lspsaga diagnostic_jump_prev", mode = "n", desc = "Prev Diagnostic" },
	{ "[e", diagnostic_goto(false, "ERROR"), mode = "n", desc = "Prev Error" },
	{ "[w", diagnostic_goto(false, "WARN"), mode = "n", desc = "Prev Warning" },
	-- Next
	{ "]", group = "next" },
	{ "]b", "<cmd>BufferNext<CR>", mode = "n", desc = "Next Buffer" },
	{ "]q", "<cmd>cnext<CR>", desc = "Next Quickfix", mode = "n" },
	{ "]d", "<cmd>Lspsaga diagnostic_jump_next", mode = "n", desc = "Next Diagnostic" },
	{ "]e", diagnostic_goto(true, "ERROR"), mode = "n", desc = "Next Error" },
	{ "]w", diagnostic_goto(true, "WARN"), mode = "n", desc = "Next Warning" },

	-- Buffer Movement
	{ "<A-x>", "<cmd>BufferClose<CR>", mode = "n" },
	{ "<C-p>", "<cmd>BufferPick<CR>", mode = "n" },

	-- Move Lines
	{ "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", mode = "n", desc = "Move Down" },
	{ "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", mode = "n", desc = "Move Up" },
	{ "<A-j>", "<esc><cmd>m .+1<cr>==gi", mode = "i", desc = "Move Down" },
	{ "<A-k>", "<esc><cmd>m .-2<cr>==gi", mode = "i", desc = "Move Up" },
	{ "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", mode = "v", desc = "Move Down" },
	{ "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", mode = "v", desc = "Move Up" },

	-- highlights under cursor
	{ "<leader>ui", vim.show_pos, mode = "n", desc = "Inspect Pos" },
	{ "<leader>uI", "<cmd>InspectTree<cr>", mode = "n", desc = "Inspect Tree" },

	-- floating terminal
	-- { "<leader>fT", function() Snacks.terminal() end, mode = "n", desc = "Terminal (cwd)" },
	-- { "<leader>ft", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, mode = "n", desc = "Terminal (Root Dir)" },
	-- { "<c-/>", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, mode = "n", desc = "Terminal (Root Dir)" },
	-- { "<c-_>", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, mode = "n", desc = "which_key_ignore" }

	{
		"\\",
		function()
			-- use treesitter to get the current expression statement
			treesitter_node_select()
			require("sniprun").run("v")
			execute_sniprun()
		end,
		mode = { "n", "v" },
		desc = "SnipRun",
	},
	-- {
	-- 	"\\",
	-- 	function()
	-- 		require("sniprun").run("v")
	-- 		execute_sniprun()
	-- 	end,
	-- 	mode = "v",
	-- 	desc = "SnipRun",
	-- },
})

-- { "", "", mode = "", desc = "" },
-- Toggle
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle
	.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
	:map("<leader>uc")
Snacks.toggle
	.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
	:map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")
if vim.lsp.inlay_hint then
	Snacks.toggle.inlay_hints():map("<leader>uh")
end

----------------------------------------------------------------------

wk.add({
	mode = { "n", "v" },

	-- Windows Movement
	{ "<leader><leader>", group = "Windows Movement", remap = false },
	{ "<leader><leader>h", "<c-w>h", desc = "Left", remap = false },
	{ "<leader><leader>j", "<c-w>j", desc = "Up", remap = false },
	{ "<leader><leader>k", "<c-w>k", desc = "Down", remap = false },
	{ "<leader><leader>l", "<c-w>l", desc = "Right", remap = false },
	{ "<leader><leader>-", "<C-W>s", mode = "n", desc = "Split Window Below", remap = true },
	{ "<leader><leader>|", "<C-W>v", mode = "n", desc = "Split Window Right", remap = true },
	{ "<leader><leader>wd", "<C-W>c", mode = "n", desc = "Delete Window", remap = true },

	-- Goto
	{ "g", group = "goto" },
	{ "gd", "<cmd>Lspsaga peek_definition<CR>", desc = "Preview Definition", remap = false },
	{ "gr", "<cmd>Lspsaga finder ref<CR>", desc = "References", nowait = true },
	{ "gI", "<cmd>Lspsaga finder imp<CR>", desc = "Goto Implementation" },
	{ "gy", "<cmd>Lspsaga peek_type_definition<CR>", desc = "Goto T[y]pe Definition" },
	{ "gD", "<cmd>Lspsaga goto_definition<CR>", desc = "Goto Declaration" },
	{ "gh", "<cmd>Lspsaga hover_doc<CR>", desc = "Lsp Hover", remap = false },
	{ "gH", vim.lsp.buf.signature_help, desc = "Lsp Hover", remap = false },

	-- Code
	{ "<leader>c", group = "Code" },
	{ "<leader>cr", "<cmd>Lspsaga rename<cr>", desc = "Rename", remap = false },
	{ "<leader>cf", "<cmd>lua vim.lsp.buf.format {async = true}<CR>", desc = "LSP Format", remap = false },
	{ "<leader>cl", "<cmd>LspInfo<cr>", desc = "LspInfo", remap = false },
	{ "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code Action", remap = false },
	{ "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" } },
	{ "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" } },
	{ "<leader>cd", vim.diagnostic.open_float, mode = "n", desc = "Line Diagnostics" },
	{ "<leader>cs", "<cmd>AerialNavToggle<cr>", mode = "n", desc = "Aerial Navigation Toggle" },
	{ "<leader>cS", "<cmd>AerialToggle<cr>", mode = "n", desc = "Aerial Toggle" },
	{ "<leader>co", "<cmd>Lspsaga outline<cr>", mode = "n", desc = "Lsp Outline" },
	{
		"<leader>cn",
		function()
			require("neogen").generate()
		end,
		desc = "Generate Annotations (Neogen)",
	},
	{
		"<a-n>",
		function()
			Snacks.words.jump(vim.v.count1, true)
		end,
		desc = "Next Reference",
	},
	{
		"<a-p>",
		function()
			Snacks.words.jump(-vim.v.count1, true)
		end,
		desc = "Prev Reference",
	},

	{
		"<leader>ll",
		"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",
		desc = "List Workspace Folders",
		remap = false,
	},

	-- Git
	{ "<leader>g", group = "Git" },

	-- Hunks
	{ "<leader>gh", group = "Hunks" },

	-- Search
	{ "<leader>s", group = "Search" },

	-- UI
	{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },

	-- Diagnostics / Quickfix
	{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },

	-- Neotree
	{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Neo-Tree", remap = false },

	-- Debug
	{ "<leader>d", group = "Debug" },

	-- File / Find
	{ "<leader>f", group = "File / Find" },
	{ "<leader>,", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
	{ "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
	{
		"<leader>fb",
		"<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
		desc = "Find File buffer",
	},
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files", remap = false },
	{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "File Files (git files)", remap = false },
	{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "File Recent", remap = false },
	-- git
	{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
	{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
	-- search
	{ '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
	{ "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
	{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
	{ "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
	{ "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
	{ "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
	{ "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
	{ "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "File Live-grep", remap = false },
	{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
	{ "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
	{ "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
	{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
	{ "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
	{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
	{ "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
	{ "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
	{ "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
	{ "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
	{ "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Find Luasnips" },
	{ "<leader>ft", "<cmd>Telescope treesitter<cr>", desc = "Lists Function names, variables, from Treesitter" },

	{ "<leader>m", group = "Markdown", remap = false },
	{ "<leader>mp", "<cmd>Glow<cr>", desc = "Markdown Preview", remap = false },
	{ "<leader>ng", ":Neogen<cr>", desc = "Annotation Toolkit", remap = false },
	{ "<leader>v", group = "Visualization of functions and args", remap = false },
	{ "<leader>vs", "<cmd>Vista<cr>", desc = "Viewer & Finder for LSP symbols and tags", remap = false },
})
