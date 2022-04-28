local lsp_installer = require("nvim-lsp-installer")

-- Include the servers you want to have installed by default below
local servers = {
	"bashls",
	"pylsp",
	"vimls",
}

for _, name in pairs(servers) do
	local server_is_found, server = lsp_installer.get_server(name)
	if server_is_found and not server:is_installed() then
		print("Installing " .. name)
		server:install()
	end
end

-- lua

lsp_installer.on_server_ready(function(server)
	-- Specify the default options which we'll use to setup all servers
	local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
	local opts = { capabilities = capabilities }
	if server.name == "remark_ls" then
		opts = vim.tbl_deep_extend("force", {
			autocmd = false,
		}, opts)
		server:setup(opts)
	elseif server.name == "sumneko_lua" then
		--lua
		local runtime_path = vim.split(package.path, ";")
		table.insert(runtime_path, "lua/?.lua")
		table.insert(runtime_path, "lua/?/init.lua")

		opts = vim.tbl_deep_extend("force", {
			-- cmd = { "/home/baiyi/.local/bin/lua-language-server/bin/lua-language-server" },
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
		}, opts)
		server:setup(opts)
	elseif server.name == "rust_analyzer" then
		require("rust-tools").setup({
			-- The "server" property provided in rust-tools setup function are the
			-- settings rust-tools will provide to lspconfig during init.            --
			-- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
			-- with the user's own settings (opts).
			server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
			tools = {
				autoSetHints = true,
				inlay_hints = {
					show_parameter_hints = true,
					show_variable_name = false,
					highlight = "Comment",
				},
			},
		})
		server:attach_buffers()
		-- Only if standalone support is needed
		-- require("rust-tools").start_standalone_if_required()
	else
		server:setup(opts)
	end
end)

-- Latex Preview
-- require("lspconfig").texlab.setup({})

-- rust
-- require("lspconfig").rust_analyzer.setup({
-- 	cmd = { "/home/baiyi/.local/bin/rust-analyzer" },
-- })
-- bash
-- require("lspconfig").bashls.setup({})

-- Latex and Markdown LSP
vim.cmd([[ autocmd BufRead,BufNewFile *.org set filetype=org ]])

-- require'lspconfig'.ltex.setup{}

-- Python LSP
-- require("lspconfig").pylsp.setup({})

-- R LSP
require("lspconfig").r_language_server.setup({
	-- cmd = {
	-- 	"R",
	-- 	"--slave",
	-- 	"-e",
	-- 	[[
	--      .libPaths(new = "~/.local/share/nvim/lsp_servers/r_language_server");
	--      langserver <- languageserver:::LanguageServer$new("localhost", NULL);
	--      .libPaths(new = Sys.getenv("R_LIBS_USER"));
	--      langserver$run()
	--    ]],
	-- },
})

-- vim LSP
require("lspconfig").vimls.setup({})
--require'lspconfig'.pyright.setup{}
--local nvim_lsp = require('lspconfig')
--typescript支持
--json支持
--require("lspconf.json")
--lua
--require("lspconf.lua")
--普通的语言支持
--require("lspconf.common")
