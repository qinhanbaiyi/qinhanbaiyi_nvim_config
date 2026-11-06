-- Git 符号与 hunk 操作。只有连接到 Git 的缓冲区才注册局部键位。
-- hunk 是一组连续差异；普通文件和可视模式的 Treesitter ]c 映射不受影响。
return {
	{
		"lewis6991/gitsigns.nvim",
		commit = "ef707fb93301a9b856f36eae4c8f56f5b988a794",
		opts = {
			-- 保留原来的轻量标记：只显示未暂存差异符号，不给整行或行号着色。
			signcolumn = true,
			signs_staged_enable = false, -- 新版默认显示已暂存符号，显式关闭以沿用旧外观。
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = {
				follow_files = true, -- Git 重命名文件后继续跟踪；新版自动使用文件事件，无需轮询 interval。
			},
			attach_to_untracked = true, -- 新文件尚未 git add 时也能看到新增行。
			current_line_blame = false, -- 默认不显示行尾作者信息，<leader>tb 随时开关。
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 作者信息放在代码行尾，不覆盖正文。
				delay = 1000, -- 光标停留一秒后显示，减少移动时闪动。
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100, -- 合并短时间内的编辑，避免每个按键都重复计算差异。
			max_file_length = 40000, -- 超大文件跳过符号更新，避免拖慢编辑。
			preview_config = {
				-- <leader>hp 的浮动预览沿用单线边框，紧贴光标右侧。
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local function map(mode, lhs, rhs, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, lhs, rhs, opts)
				end

				-- Diff 窗口返回原生 [c / ]c；普通窗口使用新 nav_hunk API。
				-- expr 映射不能直接修改窗口，调度到下一轮后执行实际跳转。
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.nav_hunk("next")
					end)
					return "<Ignore>"
				end, { expr = true })
				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.nav_hunk("prev")
					end)
					return "<Ignore>"
				end, { expr = true })

				-- 小写处理当前/选中 hunk，大写处理整份缓冲区；选区通过 Ex 范围传给插件。
				map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
				map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
				map("n", "<leader>hS", gs.stage_buffer)
				-- 保留“撤销最近一次暂存”的原语义，不改成按当前光标反向暂存。
				-- 上游保留此兼容 API；若将来删除，需先实现同等的暂存历史再迁移。
				map("n", "<leader>hu", gs.undo_stage_hunk)
				map("n", "<leader>hR", gs.reset_buffer)
				map("n", "<leader>hp", gs.preview_hunk)
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end)
				map("n", "<leader>tb", gs.toggle_current_line_blame)

				-- hd 对比 Git 索引，hD 对比上一提交；不会直接修改工作区文件。
				map("n", "<leader>hd", gs.diffthis)
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end)
				-- toggle_deleted 已失效，使用维护中的统一差异视图显示当前文件所有删除行。
				-- 再按一次关闭；保留原 <leader>td 键位，暂存/还原仍以索引为基准。
				map("n", "<leader>td", function()
					gs.diffthis(nil, { unified = true })
				end)

				-- ih 作为操作符/可视文本对象，选择整个 hunk，例如 dih 删除一块差异。
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
			end,
		},
	},
	{
		"sindrets/diffview.nvim",
		commit = "4516612fe98ff56ae0415a259ff6361a89419b0a",
		init = function(plugin)
			-- 保留原面板与历史视图，只迁移尚未在上游修复的参数校验 API。
			require("config.plugin_patches").register(plugin, require("config.compat.diffview"))
		end,
	},
}
