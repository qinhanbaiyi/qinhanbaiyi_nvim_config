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
	local name = server.name
	-- return_opts
	-- @param { any } name
	local return_opts = function(name)
		if name == "remark_ls" then
			opts = vim.tbl_deep_extend("force", {
				autocmd = false,
			}, opts)
		elseif name == "sumneko_lua" then
			local opts = require("lua-dev").setup({
				lspconfig = vim.tbl_deep_extend("force", server:get_default_options(), opts),
				library = {
					plugins = {
						"nvim-treesitter",
						"plenary.nvim",
						"telescope.nvim",
					},
				},
			})
		elseif name == "rust_analyzer" then
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
		else
			local opts = nil
		end
		return opts
	end
	local server_opts = return_opts(name)
	if server_opts == nil then
		server:setup(opts)
	else
		server:setup(server_opts)
	end
end)

-- Latex and Markdown LSP
vim.cmd([[ autocmd BufRead,BufNewFile *.org set filetype=org ]])
