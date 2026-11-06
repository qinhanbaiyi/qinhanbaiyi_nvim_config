local function format_command(args, formatters)
	local opts = { async = true, formatters = formatters }
	if args.range > 0 then
		local last_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, false)[1]
		opts.range = { start = { args.line1, 0 }, ["end"] = { args.line2, #last_line } }
	end
	require("conform").format(opts)
end

return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = { "Format", "Prettier", "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				snakemake = { "snakefmt" },
				yaml = { "yamlfmt" },
				sh = { "shfmt" },
			},
			formatters = {
				shfmt = { args = { "-i", "2" } },
			},
			format_on_save = function(bufnr)
				-- Shell files were formatted only on request with :Format.
				if vim.bo[bufnr].filetype ~= "sh" then
					return { bufnr = bufnr }
				end
			end,
		},
		config = function(_, opts)
			require("conform").setup(opts)

			vim.api.nvim_create_user_command("Format", function(args)
				format_command(args, args.args ~= "" and { args.args } or nil)
			end, { desc = "Format buffer or line range", nargs = "?", range = true, bar = true })

			vim.api.nvim_create_user_command("Prettier", function(args)
				format_command(args, { "prettier" })
			end, { desc = "Format buffer or line range with Prettier", range = true })
		end,
	},
}
