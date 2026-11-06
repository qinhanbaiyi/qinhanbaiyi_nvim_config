-- AI 兼容层只负责旧键位、命令和认证字段，实际候选渲染与网络通信交给 NeoCodeium。
local M = {}

local function reuse_legacy_auth()
	-- 两个插件使用同一个本地文件，但旧字段是 apiKey，新字段是 api_key。
	-- 仅在内存中兼容旧字段，既不打印密钥，也不复制到配置仓库或覆盖认证文件。
	local key = require("neocodeium.api_key")
	if not key.get() then
		local config = require("neocodeium.utils.conf").load()
		if type(config.apiKey) == "string" and config.apiKey ~= "" then
			key.set(config.apiKey)
		end
	end
end

function M.setup(opts)
	-- 认证模块会加载日志器，先初始化其选项，再在启动服务前复用旧认证。
	require("neocodeium.options").setup(opts)
	reuse_legacy_auth()
	local ai = require("neocodeium")
	ai.setup(opts)

	-- 新旧命令可能交替使用，以插件同步触发的 User 事件作为开关的共同来源。
	-- 缓冲区事件立即使用 ev.buf，不能延后读取当前缓冲区，否则切换窗口后会同步错对象。
	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("UserNeoCodeiumCompatibility", { clear = true }),
		pattern = { "NeoCodeiumEnabled", "NeoCodeiumDisabled", "NeoCodeiumBufEnabled", "NeoCodeiumBufDisabled" },
		desc = "Synchronize legacy Codeium switches with NeoCodeium",
		callback = function(ev)
			local disabled = ev.match == "NeoCodeiumDisabled" or ev.match == "NeoCodeiumBufDisabled"
			if ev.match == "NeoCodeiumEnabled" or ev.match == "NeoCodeiumDisabled" then
				vim.g.codeium_enabled = not disabled
			else
				vim.b[ev.buf].codeium_enabled = not disabled
			end
			if disabled and (ev.match == "NeoCodeiumDisabled" or ev.buf == vim.api.nvim_get_current_buf()) then
				-- 立即撤下旧建议并停用当前请求状态，避免同一次插入会话继续发送请求。
				ai.clear()
				require("neocodeium.state").active = false
			end
		end,
	})

	-- 使用表达式映射保留原来的回退语义，真正的编辑操作延后到 textlock 结束。
	-- 没有建议时 Ctrl-G 和原 Codeium 一样输入 Tab，原生弹出菜单可见时选择下一项。
	vim.keymap.set("i", "<C-g>", function()
		local candidate = require("neocodeium.completer"):curr_item()
		if candidate and candidate.completion and candidate.completion.text ~= "" then
			return "<Cmd>lua require('neocodeium').accept()<CR>"
		end
		return vim.g.codeium_tab_fallback or (vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>")
	end, { expr = true, silent = true, desc = "Accept AI suggestion or insert Tab" })

	local function action(lhs, rhs, desc, extra)
		vim.keymap.set("i", lhs, function()
			return rhs
		end, vim.tbl_extend("force", { expr = true, silent = true, desc = desc }, extra or {}))
	end
	action("<A-n>", "<Cmd>lua require('neocodeium').cycle(1)<CR>", "Next AI suggestion")
	action("<A-N>", "<Cmd>lua require('neocodeium').cycle(-1)<CR>", "Previous AI suggestion")
	action("<C-x>", "<Cmd>lua require('neocodeium').clear()<CR>", "Clear AI suggestion")

	-- 保留旧插件默认的备用按键。Ctrl-] 清除建议后继续执行 Vim 的缩写展开。
	action("<C-]>", "<Cmd>lua require('neocodeium').clear()<CR><C-]>", "Clear AI suggestion and expand abbreviation", {
		nowait = true,
	})
	action("<A-]>", "<Cmd>lua require('neocodeium').cycle_or_complete(1)<CR>", "Next AI suggestion or complete")
	action("<A-[>", "<Cmd>lua require('neocodeium').cycle(-1)<CR>", "Previous AI suggestion")
	-- 原 Alt-反斜杠总是重新请求，即使已有候选也不应变成循环候选。
	action("<A-Bslash>", "<Cmd>lua require('neocodeium.completer'):initiate(true)<CR>", "Request AI suggestion")

	-- 保留常用旧命令，新配置可直接使用 :NeoCodeium enable/disable/auth 等命令。
	local commands = require("neocodeium.commands")
	local actions = {
		Enable = function()
			vim.g.codeium_enabled = true
			commands.enable()
		end,
		Disable = function()
			vim.g.codeium_enabled = false
			ai.clear()
			commands.disable(true) -- 关闭服务进程，避免停用后留有后台任务。
		end,
		EnableBuffer = function()
			vim.b.codeium_enabled = true
			commands.enable_buffer()
		end,
		DisableBuffer = function()
			vim.b.codeium_enabled = false
			commands.disable_buffer()
		end,
		Auth = commands.auth,
	}
	actions.Toggle = function()
		if require("neocodeium.options").options.enabled then
			actions.Disable()
		else
			actions.Enable()
		end
	end
	actions.Manual = function()
		vim.g.codeium_manual = true
		require("neocodeium.options").options.manual = true
	end
	actions.Auto = function()
		vim.g.codeium_manual = false
		require("neocodeium.options").options.manual = false
	end
	for name, callback in pairs(actions) do
		vim.api.nvim_create_user_command("Codeium" .. name, callback, { desc = "NeoCodeium compatibility command" })
	end
	vim.api.nvim_create_user_command("Codeium", function(args)
		local callback = actions[args.args]
		if callback then
			callback()
		else
			vim.notify("Use :Codeium Enable/Disable/Toggle/Auth or :NeoCodeium", vim.log.levels.WARN)
		end
	end, {
		nargs = "?",
		complete = function()
			return vim.tbl_keys(actions)
		end,
		desc = "NeoCodeium compatibility command",
	})
end

return M
