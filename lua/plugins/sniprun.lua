return {
	{
		"michaelb/sniprun",
		branch = "master",
		filetypes = { "python", "r" },
		event = "VeryLazy",
		build = "sh install.sh",
		-- do 'sh install.sh 1' if you want to force compile locally
		-- (instead of fetching a binary from the github release). Requires Rust >= 1.65

		config = function()
			require("sniprun").setup({
				selected_interpreters = { "Python3_fifo" },
				repl_enable = { "Python3_fifo" },
				-- display = {
				-- 	"Classic",
				-- },
				display = { "Terminal" },
				display_options = {
					terminal_scrollback = vim.o.scrollback, -- change terminal display scrollback lines
					terminal_line_number = false, -- whether show line number in terminal window
					terminal_signcolumn = false, -- whether show signcolumn in terminal window
					terminal_position = "vertical", --# or "horizontal", to open as horizontal split instead of vertical split
					terminal_width = 45, --# change the terminal display option width (if vertical)
					terminal_height = 20, --# change the terminal display option height (if horizontal)
				},
				-- selected_interpreters = { "Python3_jupyter" },
				-- interpreter_options = {
				-- 	Python3_original = {
				-- 		interpreter = "python3.9",
				-- 		-- venv = { "venv_project1", "venv_project2", "../venv_project2" },
				-- 	},
				-- },
			})
		end,
	},
}
