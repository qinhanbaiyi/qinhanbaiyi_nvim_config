require("lspconfig").rust_analyzer.setup({
	settings = {
		["rust_analyzer"] = {},
	},
})
require("rust-tools").setup({
	-- The "server" property provided in rust-tools setup function are the
	-- settings rust-tools will provide to lspconfig during init.            --
	-- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
	-- with the user's own settings (opts).
	server = {
		-- standalone file support
		-- setting it to false may improve startup time
		standalone = true,
	}, -- rust-analyer options
	tools = {
		autoSetHints = true,
		inlay_hints = {
			show_parameter_hints = false,
			show_variable_name = true,
			highlight = "Comment",
			enable = true,
		},
	},
	-- debugging stuff
	dap = {
		adapter = {
			type = "executable",
			command = "lldb-vscode",
			name = "rt_lldb",
		},
	},
})
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
keymap("n", "<leader>ca", ":RustHoverActions<CR>", opts)
