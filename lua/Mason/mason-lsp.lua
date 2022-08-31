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

require("lspconfig").sumneko_lua.setup({
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
	-- 	opts = vim.tbl_deep_extend("force", {
	-- 		-- cmd = { "/home/baiyi/.local/bin/lua-language-server/bin/lua-language-server" },
	-- 	}, opts)
	-- opts = {
	-- require("lua-dev").setup({
	-- 	lspconfig = vim.tbl_deep_extend("force", server:get_default_options(), opts),
	-- 	library = {
	-- 		plugins = {
	-- 			"nvim-treesitter",
	-- 			"plenary.nvim",
	-- 			"telescope.nvim",
	-- 		},
	-- 	},
	-- }),
	-- },
})
require("lspconfig").gopls.setup({})
-- lua

-- mason_lsp.on_server_ready(function(server)
-- 	-- Specify the default options which we'll use to setup all servers
-- 	local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- 	local opts = { capabilities = capabilities }
-- 	local name = server.name
-- 	-- return_opts
-- 	-- @param { any } name
-- 	local return_opts = function(name)
-- 		if name == "remark_ls" then
-- 			opts = vim.tbl_deep_extend("force", {
-- 				autocmd = false,
-- 			}, opts)
-- 		elseif name == "sumneko_lua" then
-- 			local opts = require("lua-dev").setup({
-- 				lspconfig = vim.tbl_deep_extend("force", server:get_default_options(), opts),
-- 				library = {
-- 					plugins = {
-- 						"nvim-treesitter",
-- 						"plenary.nvim",
-- 						"telescope.nvim",
-- 					},
-- 				},
-- 			})
-- 		elseif name == "rust_analyzer" then
-- 			require("rust-tools").setup({
-- 				-- The "server" property provided in rust-tools setup function are the
-- 				-- settings rust-tools will provide to lspconfig during init.            --
-- 				-- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
-- 				-- with the user's own settings (opts).
-- 				server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
-- 				tools = {
-- 					autoSetHints = true,
-- 					inlay_hints = {
-- 						show_parameter_hints = true,
-- 						show_variable_name = false,
-- 						highlight = "Comment",
-- 					},
-- 				},
-- 			})
-- 		else
-- 			local opts = nil
-- 		end
-- 		return opts
-- 	end
-- 	local server_opts = return_opts(name)
-- 	if server_opts == nil then
-- 		server:setup(opts)
-- 	else
-- 		server:setup(server_opts)
-- 	end
-- end)
--
-- -- Latex and Markdown LSP
-- vim.cmd([[ autocmd BufRead,BufNewFile *.org set filetype=org ]])
