return {
	-- LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"hrsh7th/nvim-cmp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		opts = function()
			---@class PluginLspOpts
			local ret = {
				-- options for vim.diagnostic.config()
				---@type vim.diagnostic.Opts
				diagnostics = {
					underline = true,
					update_in_insert = false,
					virtual_text = {
						spacing = 4,
						source = "if_many",
						prefix = "●",
						-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
						-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
						-- prefix = "icons",
					},
					severity_sort = true,
					signs = {},
				},
				-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
				-- Be aware that you also will need to properly configure your LSP server to
				-- provide the inlay hints.
				inlay_hints = {
					enabled = true,
					exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
				},
				-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
				-- Be aware that you also will need to properly configure your LSP server to
				-- provide the code lenses.
				codelens = {
					enabled = false,
				},
				-- add any global capabilities here
				capabilities = {
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},
				-- options for vim.lsp.buf.format
				-- `bufnr` and `filter` is handled by the LazyVim formatter,
				-- but can be also overridden when specified
				format = {
					formatting_options = nil,
					timeout_ms = nil,
				},
				-- LSP Server Settings
				---@type lspconfig.options
				servers = {
					lua_ls = {
						-- mason = false, -- set to false if you don't want this server to be installed with mason
						-- Use this to add any additional keymaps
						-- for specific lsp servers
						-- ---@type LazyKeysSpec[]
						-- keys = {},
						settings = {
							Lua = {
								workspace = {
									checkThirdParty = false,
								},
								codeLens = {
									enable = true,
								},
								completion = {
									callSnippet = "Replace",
								},
								doc = {
									privateName = { "^_" },
								},
								hint = {
									enable = true,
									setType = false,
									paramType = true,
									paramName = "Disable",
									semicolon = "Disable",
									arrayIndex = "Disable",
								},
							},
						},
					},
					rust_analyzer = {
						filetypes = { "rust" },
						cmd = { "rust-analyzer" },
					},
				},
				-- you can do any additional lsp server setup here
				-- return true if you don't want this server to be setup with lspconfig
				---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
				setup = {
					-- example to setup with typescript.nvim
					-- tsserver = function(_, opts)
					--   require("typescript").setup({ server = opts })
					--   return true
					-- end,
					-- Specify * to use this function as a fallback for any server
					["*"] = function(server, opts) end,
				},
			}
			return ret
		end,
		config = function(_, opts)
			local lsp = require("lspconfig")
			if opts.inlay_hints.enabled then
				vim.api.nvim_create_autocmd("LspAttach", {
					desc = "Enable inlay hints",
					callback = function(args)
						local id = vim.tbl_get(args, "data", "client_id")
						local client = id and vim.lsp.get_client_by_id(id)
						if client == nil or not client.supports_method("textDocument/inlayHint") then
							return
						end

						vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
					end,
				})
			end
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			local servers = opts.servers
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local has_blink, blink = pcall(require, "blink.cmp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				has_cmp and cmp_nvim_lsp.default_capabilities() or {},
				has_blink and blink.get_lsp_capabilities() or {},
				opts.capabilities or {}
			)

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})
				if server_opts.enabled == false then
					return
				end

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end
			-- get all the servers that are available through mason-lspconfig
			local have_mason, mlsp = pcall(require, "mason-lspconfig")
			local all_mslp_servers = {}
			if have_mason then
				all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			end

			local ensure_installed = {
				"bashls",
				-- "pylsp",
				-- "basedpyright",
				"vimls",
				"lua_ls",
				"rust_analyzer",
			} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					if server_opts.enabled ~= false then
						-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
						if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
							setup(server)
						else
							ensure_installed[#ensure_installed + 1] = server
						end
					end
				end
			end

			if have_mason then
				mlsp.setup({
					-- ensure_installed = vim.tbl_deep_extend("force", ensure_installed),
					ensure_installed = vim.tbl_deep_extend("force", ensure_installed, {}),
					handlers = { setup },
				})
			end
		end,
	},
	{
		"glepnir/lspsaga.nvim",
		branch = "main",
		init = function()
			-- Latex and Markdown LSP
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { "*.org" },
				command = "set filetype=org",
			})
		end,
		config = function()
			require("lspsaga").setup({
				finder = {
					methods = {},
				},
			})
		end,
	},
	-- 美化
	{
		"folke/lsp-colors.nvim",
		opts = {
			Error = "#db4b4b",
			Warning = "#e0af68",
			Information = "#0db9d7",
			Hint = "#10B981",
		},
	},

	-- 参数
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},

	-- 美化自动完成提示信息
	{ "onsails/lspkind-nvim" },

	-- Mason
	{
		"williamboman/mason.nvim",
		opts = {},
		-- opts = {
		-- 	-- ensure_installed = {
		-- 	-- 	"bashls",
		-- 	-- 	"pylsp",
		-- 	-- 	"vimls",
		-- 	-- 	"lua_ls",
		-- 	-- 	"rust_analyzer",
		-- 	-- },
		-- },
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {},
		-- opts = function()
		-- 	-- Include the servers you want to have installed by default below
		-- 	local server_opts = {
		-- 		lua_ls = {
		-- 			settings = {
		-- 				Lua = {
		-- 					runtime = {
		-- 						-- Tell the language server which version of Lua you're using
		-- 						-- (most likely LuaJIT in the case of Neovim)
		-- 						version = "LuaJIT",
		-- 					},
		-- 					-- Make the server aware of Neovim runtime files
		-- 					workspace = {
		-- 						checkThirdParty = false,
		-- 						library = {
		-- 							vim.env.VIMRUNTIME,
		-- 							vim.fn.stdpath("data") .. "/lazy/",
		-- 							-- "${3rd}/luv/library"
		-- 							-- "${3rd}/busted/library",
		-- 						},
		-- 						-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
		-- 						-- library = vim.api.nvim_get_runtime_file("", true),
		-- 					},
		-- 					codeLens = {
		-- 						enable = true,
		-- 					},
		-- 					hint = {
		-- 						enable = true,
		-- 						settype = false,
		-- 						paramType = true,
		-- 						paramName = "Disable",
		-- 						semicolon = "Disable",
		-- 						arrayIndex = "Disable",
		-- 					},
		-- 				},
		-- 			},
		-- 		},
		-- 		rust_analyzer = {
		-- 			filetypes = { "rust" },
		-- 			cmd = { "rust-analyzer" },
		-- 		},
		-- 	}
		--
		-- 	local server_handlers = {
		-- 		function(server_name)
		-- 			-- Specify the default options which we'll use to setup all servers
		-- 			local common_capabilities = vim.tbl_deep_extend(
		-- 				"force",
		-- 				{},
		-- 				vim.lsp.protocol.make_client_capabilities(),
		-- 				require("cmp_nvim_lsp").default_capabilities() or {}
		-- 			)
		-- 			local opts = vim.tbl_deep_extend("force", {
		-- 				capabilities = vim.deepcopy(common_capabilities),
		-- 			}, server_opts[server_name] or {})
		-- 			require("lspconfig")[server_name].setup(opts)
		-- 		end,
		-- 	}
		--
		-- 	return {
		-- 		automatically_install = true,
		-- 		handlers = server_handlers,
		-- 		inlay_hints = {
		-- 			enabled = true,
		-- 			exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
		-- 		},
		-- 		-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
		-- 		-- Be aware that you also will need to properly configure your LSP server to
		-- 		-- provide the code lenses.
		-- 		codelens = {
		-- 			enabled = false,
		-- 		},
		-- 		-- Enable lsp cursor word highlighting
		-- 		document_highlight = {
		-- 			enabled = true,
		-- 		},
		-- 	}
		-- end,
	},

	-- -- highlight the word under the cursor
	-- { "RRethy/vim-illuminate", opts = nil },

	-- add symbols-outline
	{
		"simrat39/symbols-outline.nvim",
		cmd = "SymbolsOutline",
		opts = nil,
		-- opts = {
		-- 	-- add your options that should be passed to the setup() function here
		-- 	position = "right",
		-- },
	},
}
