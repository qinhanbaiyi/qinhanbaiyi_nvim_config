local wk = require("which-key")

-- diagnostic
local diagnostic_goto = function(next, severity)
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		vim.diagnostic.jump({
			count = next and 1 or -1,
			severity = severity,
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
			end,
		})
	end
end

wk.add({
	---@group [ and ] for buffer navigation
	-- Prev
	{ "[", group = "prev" },
	{ "[b", "<cmd>BufferPrevious<CR>", mode = "n", desc = "Previous Buffer" },
	{ "[q", "<cmd>cprev<CR>", desc = "Previous Quickfix", mode = "n" },
	{ "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", mode = "n", desc = "Prev Diagnostic" },
	{ "[e", diagnostic_goto(false, "ERROR"), mode = "n", desc = "Prev Error" },
	{ "[w", diagnostic_goto(false, "WARN"), mode = "n", desc = "Prev Warning" },
	-- Next
	{ "]", group = "next" },
	{ "]b", "<cmd>BufferNext<CR>", mode = "n", desc = "Next Buffer" },
	{ "]q", "<cmd>cnext<CR>", desc = "Next Quickfix", mode = "n" },
	{ "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", mode = "n", desc = "Next Diagnostic" },
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
})

-- Display and diagnostic toggles
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
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")
if vim.lsp.inlay_hint then
	Snacks.toggle.inlay_hints():map("<leader>uh")
end

wk.add({
	mode = { "n", "v" },

	-- Windows Movement
	{ "<leader><leader>", group = "Windows Movement", remap = false },
	{ "<leader><leader>h", "<c-w>h", desc = "Left", remap = false },
	{ "<leader><leader>j", "<c-w>j", desc = "Down", remap = false },
	{ "<leader><leader>k", "<c-w>k", desc = "Up", remap = false },
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
	{ "gD", "<cmd>Lspsaga goto_definition<CR>", desc = "Go to Definition" },
	{ "gh", "<cmd>Lspsaga hover_doc<CR>", desc = "Lsp Hover", remap = false },
	{ "gH", vim.lsp.buf.signature_help, desc = "Signature Help", remap = false },

	-- Code
	{ "<leader>c", group = "Code" },
	{ "<leader>cr", "<cmd>Lspsaga rename<cr>", desc = "Rename", remap = false },
	{ "<leader>cf", "<cmd>lua vim.lsp.buf.format {async = true}<CR>", desc = "LSP Format", remap = false },
	{ "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", desc = "LSP Health", remap = false },
	{ "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code Action", remap = false },
	{ "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" } },
	{ "<leader>cC", function() vim.lsp.codelens.enable(true, { bufnr = 0 }) end, desc = "Refresh & Display Codelens", mode = { "n" } },
	{ "<leader>cd", vim.diagnostic.open_float, mode = "n", desc = "Line Diagnostics" },
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
	{ "<leader>ug", "<cmd>IBLToggle<cr>", mode = "n", desc = "Toggle Indent Guides" },

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
	{ "<leader>v", group = "Symbols", remap = false },
})
