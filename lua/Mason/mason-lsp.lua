local mason_lsp = require("mason-lspconfig")
mason_lsp.setup({
	ensure_installed = {
		"sumneko_lua",
		"rust_analyzer",
		"bashls",
		"pylsp",
		"vimls",
	},
})

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
local opts = { capabilities = capabilities }
--lua
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local lsp = vim.api.nvim_create_augroup("LSP", { clear = true })
-- Lua
vim.api.nvim_create_autocmd("FileType", {
	group = lsp,
	pattern = "lua",
	callback = function()
		local path = vim.fs.find({ ".luarc.json", ".luacheckrc", "stylua.toml", ".git" })
		vim.lsp.start({
			name = "lua-language-server",
			cmd = { "lua-language-server" },
			root_dir = vim.fs.dirname(path[1]),
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
						preloadFileSize = 10000,
						maxPreload = 10000,
						checkThirdParty = false,
					},
					-- Do not send telemetry data containing a randomized but unique identifier
					telemetry = {
						enable = false,
					},
				},
			},
		})
	end,
})

-- Rust
vim.api.nvim_create_autocmd("FileType", {
	group = lsp,
	pattern = "rust",
	callback = function()
		local path = vim.fs.find({ "Cargo.toml" }, { type = "file" })
		vim.lsp.start({
			name = "rust-analyzer",
			cmd = { "rust-analyzer" },
			root_dir = vim.fs.dirname(path[1]),
			settings = {
				["rust-analyzer"] = {
					cargo = { allFeatures = true },
					checkOnSave = { allFeatures = true, command = "clippy" },
				},
			},
		})
	end,
})

-- Go
vim.api.nvim_create_autocmd("FileType", {
	group = lsp,
	pattern = "go",
	callback = function()
		vim.lsp.start({
			name = "gopls",
			cmd = { "gopls" },
			settings = {},
		})
	end,
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
			show_parameter_hints = true,
			show_variable_name = false,
			highlight = "Comment",
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
-- Latex and Markdown LSP
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.org" },
	callback = function()
		vim.bo.filetype = "org"
	end,
})
