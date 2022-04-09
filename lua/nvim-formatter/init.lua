----------------------------------------------------------------------
----------------------------- FORMAT ---------------------------------
----------------------------------------------------------------------
require("formatter").setup({
	filetype = {
		sh = {
			function()
				return {
					exe = "shfmt",
					args = { "-i", 2 },
					stdin = true,
				}
			end,
		},
		rust = {
			function()
				return {
					exe = "rustfmt",
					args = { "--emit=stdout" },
					stdin = true,
				}
			end,
		},
		markdown = {
			function()
				return {
					exe = "npx prettier",
					args = {
						"--config-precedence",
						"prefer-file",
						-- you can add more global setup here
						"--stdin-filepath",
						vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
					},
					stdin = true,
				}
			end,
		},
		lua = {
			function()
				return {
					exe = "stylua",
					args = {
						-- "--config-path "
						--   .. os.getenv("XDG_CONFIG_HOME")
						--   .. "/stylua/stylua.toml",
						"-",
					},
					stdin = true,
				}
			end,
		},
		python = {
			function()
				return {
					exe = "black",
					args = { "-" },
					stdin = true,
				}
			end,
		},
		json = {
			function()
				return {
					exe = "prettier",
					args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), "--double-quote" },
					stdin = true,
				}
			end,
		},
	},
})
----------------------------------------------------------------------
------------------------ AUTOMATE FORMAT -----------------------------
----------------------------------------------------------------------
-- automate format
vim.api.nvim_exec(
	[[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.rs FormatWrite
  autocmd BufWritePost *.md FormatWrite
  autocmd BufWritePost *.lua FormatWrite
  autocmd BufWritePost *.py FormatWrite
  autocmd BufWritePost *.sh FormatWrite
augroup END
]],
	true
)
