local null_ls = require("null-ls")
local prettier = require("prettier")
local keymap = vim.keymap.set

null_ls.setup({
	on_attach = function(client, bufnr)
		if client.resolved_capabilities.document_formatting then
			keymap("n", "<leader>lf", ":lua vim.lsp.buf.formatting()<CR>", { silent = true, noremap = true })
			-- format on save
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				pattern = { "*" },
				callback = function()
					vim.lsp.buf.formatting()
				end,
			})
		end

		if client.resolved_capabilities.document_range_formatting then
			keymap("x", "<leader>lf", ":lua vim.lsp.buf.range_formatting({})<CR>", { silent = true, noremap = true })
		end
	end,
})

prettier.setup({
	bin = "prettier", -- or `prettierd`
	filetypes = {
		"css",
		"graphql",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"less",
		"markdown",
		"scss",
		"typescript",
		"typescriptreact",
		"yaml",
	},

	-- prettier format options (you can use config files too. ex: `.prettierrc`)
	arrow_parens = "always",
	bracket_spacing = true,
	embedded_language_formatting = "auto",
	end_of_line = "lf",
	html_whitespace_sensitivity = "css",
	jsx_bracket_same_line = false,
	jsx_single_quote = false,
	print_width = 80,
	prose_wrap = "preserve",
	quote_props = "as-needed",
	semi = true,
	single_quote = false,
	tab_width = 2,
	trailing_comma = "es5",
	use_tabs = false,
	vue_indent_script_and_style = false,
})
