-- 用 Neovim 原生浮窗和现有 Glow CLI 替代归档的 glow.nvim，保留原来的预览入口。
-- 只向子进程传递 Markdown 内容，不经过 shell，也不保存或修改正在编辑的文件。
local M = {}
local preview

local filetypes = {
	markdown = true,
	["markdown.pandoc"] = true,
	["markdown.gfm"] = true,
	wiki = true,
	vimwiki = true,
	telekasten = true,
}
local extensions = {
	md = true,
	markdown = true,
	mkd = true,
	mkdn = true,
	mdwn = true,
	mdown = true,
	mdtxt = true,
	mdtext = true,
	rmd = true,
	wiki = true,
}

-- 关闭当前预览时终止未完成的渲染，旧进程的迟到结果不会写入下一次浮窗。
function M.close()
	local current = preview
	preview = nil
	if not current then
		return
	end
	if current.job then
		current.job:kill(15)
	end
	if vim.api.nvim_win_is_valid(current.win) then
		vim.api.nvim_win_close(current.win, true)
	end
end

---@param path? string 为空时使用当前缓冲区，包含未保存的修改。
function M.open(path)
	if vim.fn.executable("glow") ~= 1 then
		vim.notify("Markdown 预览需要 PATH 中的 glow 程序", vim.log.levels.ERROR)
		return
	end

	local lines
	if path and path ~= "" then
		if not extensions[vim.fn.fnamemodify(path, ":e"):lower()] then
			vim.notify("Glow 只预览 Markdown 文件", vim.log.levels.WARN)
			return
		end
		local ok, result = pcall(vim.fn.readfile, path)
		if not ok then
			vim.notify("无法读取 Markdown 文件：" .. path, vim.log.levels.ERROR)
			return
		end
		lines = result
	else
		if not filetypes[vim.bo.filetype] then
			vim.notify("Glow 只预览 Markdown 缓冲区", vim.log.levels.WARN)
			return
		end
		lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	end

	M.close()
	-- 保留原先 70% 窗口比例、100 列上限和阴影边框，并适配较小的终端。
	local width = math.max(1, math.min(100, math.ceil(vim.o.columns * 0.7), vim.o.columns - 2))
	local height = math.max(1, math.min(100, math.ceil(vim.o.lines * 0.7), vim.o.lines - vim.o.cmdheight - 2))
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = "shadow",
		width = width,
		height = height,
		row = math.max(0, math.ceil((vim.o.lines - height) / 2 - 1)),
		col = math.max(0, math.ceil((vim.o.columns - width) / 2)),
	})
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "glowpreview"
	vim.wo[win].winblend = 0
	local current = { win = win, buf = buf }
	preview = current
	local channel = vim.api.nvim_open_term(buf, {})
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, M.close, { buffer = buf, silent = true, desc = "Close Markdown preview" })
	end
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		once = true,
		callback = function()
			if preview == current then
				preview = nil
				if current.job then
					current.job:kill(15)
				end
			end
		end,
	})

	-- stdin 可处理未命名文件和带空格路径；open_term 保留 Glow 的 ANSI 颜色。
	local ok, job = pcall(
		vim.system,
		{ "glow", "-s", vim.o.background, "-w", tostring(width), "-" },
		{
			stdin = table.concat(lines, "\n") .. "\n",
			text = true,
		},
		vim.schedule_wrap(function(result)
			current.job = nil
			if preview ~= current or not vim.api.nvim_buf_is_valid(buf) then
				return
			end
			if result.code ~= 0 then
				M.close()
				vim.notify("Glow 渲染失败：" .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
				return
			end
			local output = (result.stdout or ""):gsub("\n", "\r\n")
			vim.api.nvim_chan_send(channel, output)
		end)
	)
	if ok then
		current.job = job
	else
		M.close()
		vim.notify("无法启动 Glow：" .. tostring(job), vim.log.levels.ERROR)
	end
end

function M.setup()
	vim.api.nvim_create_user_command("Glow", function(args)
		if preview and vim.api.nvim_get_current_win() == preview.win then
			if args.bang then
				M.close()
			end
			return
		end
		M.open(args.fargs[1])
	end, { nargs = "?", bang = true, complete = "file", desc = "Preview Markdown with Glow" })
	vim.keymap.set({ "n", "v" }, "<leader>mp", "<cmd>Glow<cr>", {
		silent = true,
		remap = false,
		desc = "Markdown Preview",
	})
end

return M
