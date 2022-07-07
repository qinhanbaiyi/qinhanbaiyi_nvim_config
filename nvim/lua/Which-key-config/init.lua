----------------------------------------------------------------------
---------------------------- Default Setup ---------------------------
----------------------------------------------------------------------
require("which-key").setup({
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		spelling = {
			enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
			suggestions = 20, -- how many suggestions should be shown in the list?
		},
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		presets = {
			operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
			motions = true, -- adds help for motions
			text_objects = true, -- help for text objects triggered after entering an operator
			windows = true, -- default bindings on <c-w>
			nav = true, -- misc bindings to work with windows
			z = true, -- bindings for folds, spelling and others prefixed with z
			g = true, -- bindings for prefixed with g
		},
	},
	-- add operators that will trigger motion and text object completion
	-- to enable all native operators, set the preset / operators plugin above
	operators = { gc = "Comments", gb = "Comment block" },
	key_labels = {
		-- override the label used to display some keys. It doesn't effect WK in any other way.
		-- For example:
		-- ["<space>"] = "SPC",
		-- ["<cr>"] = "RET",
		-- ["<tab>"] = "TAB",
	},
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	popup_mappings = {
		scroll_down = "<c-d>", -- binding to scroll down inside the popup
		scroll_up = "<c-u>", -- binding to scroll up inside the popup
	},
	window = {
		border = "single", -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
		padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
		winblend = 0,
	},
	layout = {
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
		align = "left", -- align columns left, center or right
	},
	ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
	show_help = true, -- show help message on the command line when the popup is visible
	triggers = "auto", -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specify a list manually
	triggers_blacklist = {
		-- list of mode / prefixes that should never be hooked by WhichKey
		-- this is mostly relevant for key maps that start with a native binding
		-- most people should not need to change this
		i = { "j", "k" },
		v = { "j", "k" },
	},
})

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
wk.register({
	["<leader>"] = {
		e = { "<cmd>NvimTreeToggle<CR>", "Nvim-Tree" },
		m = {
			name = "Markdown",
			p = { "<cmd>Glow<cr>", "Markdown Preview" },
		},
		n = {
			g = { ":Neogen<cr>", "Annotation Toolkit" },
		},
		c = {
			name = "Lua Config File",
			i = { ":e ~/.config/nvim/init.lua<cr>", "Init Config" },
			p = { ":e ~/.config/nvim/lua/plugins/init.lua<cr>", "Plugins Config" },
		},
		v = {
			name = "Visualization of functions and args",
			s = { "<cmd>Vista<cr>", "Viewer & Finder for LSP symbols and tags" },
		},
		f = {
			name = "file",
			f = { "<cmd>Telescope find_files<cr>", "Find File" },
			g = { "<cmd>Telescope live_grep<cr>", "File Live-grep" },
			b = { "<cmd>Telescope buffers<cr>", "Find File buffer" },
			h = { "<cmd>Telescope help_tags<cr>", "Find Help tags" },
		},
		l = {
			name = "LSP",
			i = { "<cmd>LspInfo<cr>", "LspInfo" },
			d = { "<cmd>lua vim.diagnostic.open_float()<CR>", "LSP diagnostic" },
			dl = { ":Lspsaga show_line_diagnostics<CR>", "LSP diagnostic list" },
			s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature Help" },
			h = { "<cmd>Lspsaga hover_doc<cr>", "Hover Commands" },
			w = { "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", "Add Workspace Folder" },
			W = { "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", "Remove Workspace Folder" },
			l = {
				"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",
				"List Workspace Folders",
			},
			t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type Definition" },
			de = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go To Definition" },
			D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go To Declaration" },
			r = { "<cmd>lua vim.lsp.buf.references()<cr>", "References" },
			R = { "<cmd>Lspsaga rename<cr>", "Rename" },
			a = { "<cmd>Lspsaga code_action<cr>", "Code Action" },
			e = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Show Line Diagnostics" },
			n = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "Go To Next Diagnostic" },
			N = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Go To Previous Diagnostic" },
			f = { "<cmd>lua vim.lsp.buf.format { async = true }<CR>", "LSP Format" },
		},
		ga = { "<cmd>Lspsaga lsp_finder<CR>", "Async Lsp Finder" },
		ca = { "<cmd>Lspsaga code_action<CR>", "Code Action" },
		gd = { "<cmd>Lspsaga preview_definition<CR>", "Preview Definition" },
		gr = { "<cmd>Lspsaga rename<CR>", "Rename" },
		gs = { "<cmd>Lspsaga signature_help<CR>", "SignatureHelp" },
		gh = { "<cmd>Lspsaga hover_doc<CR>", "Lsp Hover" },
	},
	["<leader><leader>"] = {
		name = "Windows Movement",
		h = { "<c-w>h", "Left" },
		j = { "<c-w>j", "Up" },
		k = { "<c-w>k", "Down" },
		l = { "<c-w>l", "Right" },
	},
}, {
	noremap = true,
	silent = true,
})
----------------------------------------------------------------------
---------------------------- Setup -----------------------------------
----------------------------------------------------------------------
