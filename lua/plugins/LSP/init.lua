return {
	{
		"neovim/nvim-lspconfig",
		version = "v2.12.0",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"hrsh7th/nvim-cmp",
			{ "mason-org/mason.nvim", version = "v2.3.1", opts = {} },
			{ "mason-org/mason-lspconfig.nvim", version = "v2.3.0" },
		},
		config = function()
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
				signs = {},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "Enable inlay hints",
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client:supports_method("textDocument/inlayHint", args.buf) then
						vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
					end
				end,
			})

			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local has_blink, blink = pcall(require, "blink.cmp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				has_cmp and cmp_nvim_lsp.default_capabilities() or {},
				has_blink and blink.get_lsp_capabilities() or {},
				{
					workspace = {
						fileOperations = { didRename = true, willRename = true },
					},
				}
			)
			vim.lsp.config("*", { capabilities = capabilities })
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						codeLens = { enable = true },
						completion = { callSnippet = "Replace" },
						doc = { privateName = { "^_" } },
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
			})
			vim.lsp.config("rust_analyzer", {
				filetypes = { "rust" },
				cmd = { "rust-analyzer" },
			})
			require("mason-lspconfig").setup({
				ensure_installed = { "bashls", "vimls", "lua_ls", "rust_analyzer" },
				-- Keep Tombi available for manual use as before.
				automatic_enable = { exclude = { "tombi" } },
			})
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
