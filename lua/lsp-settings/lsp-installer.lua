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
						library = vim.api.nvim_get_runtime_file("", true),
					},
					-- Do not send telemetry data containing a randomized but unique identifier
					telemetry = {
						enable = false,
					},
				},
			},
		}, opts)
	elseif server.name == "rust_analyzer" then
		local options = {
			tools = {
				autoSetHints = true,
				inlay_hints = {

					-- Only show inlay hints for the current line
					only_current_line = false,

					-- Event which triggers a refersh of the inlay hints.
					-- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
					-- not that this may cause higher CPU usage.
					-- This option is only respected when only_current_line and
					-- autoSetHints both are true.
					only_current_line_autocmd = "CursorHold",

					-- whether to show parameter hints with the inlay hints or not
					-- default: true
					show_parameter_hints = true,

					-- whether to show variable name before type hints with the inlay hints or not
					-- default: false
					show_variable_name = false,

					-- prefix for parameter hints
					-- default: "<-"
					parameter_hints_prefix = "<- ",

					-- prefix for all the other hints (type, chaining)
					-- default: "=>"
					other_hints_prefix = "=> ",

					-- whether to align to the lenght of the longest line in the file
					max_len_align = false,

					-- padding from the left if max_len_align is true
					max_len_align_padding = 1,

					-- whether to align to the extreme right or not
					right_align = false,

					-- padding from the right if right_align is true
					right_align_padding = 7,

					-- The color of the hints
					highlight = "Comment",
				},
			},
		}
		require("rust-tools").setup({
			-- The "server" property provided in rust-tools setup function are the
			-- settings rust-tools will provide to lspconfig during init.            --
			-- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
			-- with the user's own settings (opts).
			server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
			options,
		})
		server:attach_buffers()
		-- Only if standalone support is needed
		-- require("rust-tools").start_standalone_if_required()
	end

	server:setup(opts)
end)

-- Latex Preview
require("lspconfig").texlab.setup({})

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
