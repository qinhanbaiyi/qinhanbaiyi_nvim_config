return {

	-- Format plugs
	{ "nvim-lua/plenary.nvim" },

	-- Formatter
	{
		"mhartington/formatter.nvim",
		-- init = function()
		-- 	vim.api.nvim_create_autocmd("BufWritePost", {
		-- 		pattern = { "*.rs", "*.md", "*.lua", "*.py", "*.sh", "*.c", "*.cpp", "*.json", "*.tex", "*.smk", "*.yml", "*.yaml", },
		-- 		command = "FormatWrite",
		-- 	})
		-- end,
		opts = {
			filetype = {
				sh = { function() return { exe = "shfmt", args = { "-i", 2 }, stdin = true, } end, },
				-- rust = { function() return { exe = "rustfmt", args = { "--emit=stdout" }, stdin = true, } end, },
				-- markdown = {
				-- 	function()
				-- 		return { exe = "prettier", args = { "--config-precedence", "prefer-file", -- you can add more global setup here "--stdin-filepath", vim.fn.shellescape(vim.api.nvim_buf_get_name(0)), }, stdin = true, } end,
				-- },
				-- c = {
				-- 	-- clang-format
				-- 	function()
				-- 		return { exe = "clang-format", args = { "--assume-filename", vim.api.nvim_buf_get_name(0) }, stdin = true, cwd = vim.fn.expand("%:p:h"), -- Run clang-format in cwd of the file. }
				-- 	end,
				-- },
				-- cpp = {
				-- 	-- clang-format
				-- 	function()
				-- 		return { exe = "clang-format", args = { "--assume-filename", vim.api.nvim_buf_get_name(0) }, stdin = true, cwd = vim.fn.expand("%:p:h"), -- Run clang-format in cwd of the file. }
				-- 	end,
				-- },
				-- lua = {
				-- 	function()
				-- 		return { exe = "stylua", args = { -- "--config-path " --   .. os.getenv("XDG_CONFIG_HOME") --   .. "/stylua/stylua.toml", "-", }, stdin = true, }
				-- 	end,
				-- },
				-- python = {
				-- 	function()
				-- 		return { exe = "black", args = { "-" }, stdin = true, }
				-- 	end,
				-- },
				-- json = {
				-- 	function() return { exe = "prettier", args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), "--double-quote", }, stdin = true, } end,
				-- },
				-- tex = {
				-- 	function()
				-- 		return { exe = "latexindent", args = { "-" }, stdin = true, }
				-- 	end,
				-- },
				-- snakemake = {
				-- 	function()
				-- 		return { exe = "snakefmt", args = { "-" }, stdin = true, }
				-- 	end,
				-- },
				-- yaml = {
				-- 	function()
				-- 		return { exe = "yamlfmt", args = { "-" }, stdin = true, }
				-- 	end,
				-- },
			},
		},
		config = false,
	},
	{ "jose-elias-alvarez/null-ls.nvim" },
	{ "MunifTanjim/prettier.nvim" },
	{ "lukas-reineke/indent-blankline.nvim" },
	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					-- Conform will run multiple formatters sequentially
					python = { "black" },
					-- You can customize some of the format options for the filetype (:help conform.format)
					rust = { "rustfmt", lsp_format = "fallback" },
					-- Conform will run the first available formatter
					javascript = { "prettierd", "prettier", stop_after_first = true },
					snakemake = { "snakefmt" },
					yaml = { "yamlfmt" },
				},
			})
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})
		end,
	},
}
