local luadev = require("lua-dev").setup({
	-- add any options here, or leave empty to use the default settings
	lspconfig = {
		cmd = { "lua-language-server" },
	},
	library = {
		enabled = true, -- when not enabled, lua-dev will not change any settings to the LSP server
		-- these settings will be used for your neovim config directory
		runtime = true, -- runtime path
		types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
		plugins = true, -- installed opt or start plugins in packpath
		-- you can also specify the list of plugins to make available as a workspace library
		plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
	},
})

local lspconfig = require("lspconfig")
lspconfig.sumneko_lua.setup(luadev)
-- 详情见 lsp-installer.lua
