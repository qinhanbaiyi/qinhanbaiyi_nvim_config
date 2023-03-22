require("mason-lspconfig").setup({
	ensure_installed = {
		"rust_analyzer",
		"bashls",
		"vimls",
	},
})
local lsp = require("lspconfig")

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local opts = { capabilities = capabilities }
--lua
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lsp.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Setup your lua path
				path = runtime_path,
			},

			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
				-- Make the server aware of Neovim runtime files
				-- library = vim.api.nvim_get_runtime_file("", true),
				-- preloadFileSize = 10000,
				-- maxPreload = 10000,
				-- checkThirdParty = false,
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
			completion = {
				callSnippet = "Replace",
			},
		},
	},
})

-- Go
lsp.texlab.setup({})
-- lsp.pylsp.setup({})
lsp.pyright.setup({})
-- lsp.eslint.setup({})
lsp.tsserver.setup({})
lsp.perlnavigator.setup({})
lsp.bashls.setup({})
-- lsp.vuels.setup({})
-- lsp.volar.setup({
-- 	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
-- })
lsp.tailwindcss.setup({})

lsp.dockerls.setup({})
-- lsp.rome.setup({})

-- Latex and Markdown LSP
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.org" },
	callback = function()
		vim.bo.filetype = "org"
	end,
})
