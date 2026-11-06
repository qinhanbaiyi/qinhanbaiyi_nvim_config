-- 执行当前语句或可视选区，并把光标推进到下一段，保持交互式执行习惯。
-- 返回从 1 开始的闭区间行号。普通模式向上查找语句，选区模式使用实际范围。
---@return integer first_line
---@return integer last_line
local function sniprun_range()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	if vim.fn.mode():find("[vV\22]") then
		local anchor = vim.fn.line("v")
		vim.cmd.normal({ args = { vim.keycode("<Esc>") }, bang = true })
		return math.min(anchor, line), math.max(anchor, line)
	end

	local parser = vim.treesitter.get_parser(0)
	if not parser then
		return line, line
	end
	parser:parse()
	local node = vim.treesitter.get_node()
	if not node then
		return line, line
	end
	while not node:type():find("statement", 1, true) and node:type() ~= "function_definition" do
		local parent = node:parent()
		if not parent or not parent:parent() then
			break
		end
		node = parent
	end

	local start_row, _, end_row, end_col = node:range()
	-- Tree-sitter 的结束位置为开区间，末列为 0 时不包含最后一行。
	if end_col == 0 and end_row > start_row then
		end_row = end_row - 1
	end
	return start_row + 1, end_row + 1
end

-- 提交执行请求后移动到下一行，文件末尾则停在最后一行。
local function execute_sniprun()
	local first, last = sniprun_range()
	require("sniprun.api").run_range(first, last)
	local total_lines = vim.api.nvim_buf_line_count(0)
	if last >= total_lines then
		vim.api.nvim_win_set_cursor(0, { total_lines, 0 })
	else
		vim.api.nvim_win_set_cursor(0, { last + 1, 9999 })
	end
end

return {
	{
		"michaelb/sniprun",
		branch = "master",
		event = "VeryLazy",
		keys = {
			{ "\\", execute_sniprun, mode = { "n", "v" }, desc = "SnipRun" },
			{ "R", ":SnipRun<CR>", mode = "s", desc = "SnipRun", silent = true },
		},
		build = "sh install.sh",
		-- do 'sh install.sh 1' if you want to force compile locally
		-- (instead of fetching a binary from the github release). Requires Rust >= 1.65

		config = function()
			require("sniprun").setup({
				selected_interpreters = { "Python3_fifo" },
				repl_enable = { "Python3_fifo" },
				display = { "Terminal" },
				display_options = {
					terminal_scrollback = vim.o.scrollback, -- change terminal display scrollback lines
					terminal_line_number = false, -- whether show line number in terminal window
					terminal_signcolumn = false, -- whether show signcolumn in terminal window
					terminal_position = "vertical", --# or "horizontal", to open as horizontal split instead of vertical split
					terminal_width = 45, --# change the terminal display option width (if vertical)
					terminal_height = 20, --# change the terminal display option height (if horizontal)
				},
			})
		end,
	},
}
