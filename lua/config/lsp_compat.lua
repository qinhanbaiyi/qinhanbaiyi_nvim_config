-- 固定的 Lspsaga cf6fc94 仍有两处未适配新版 Neovim 的调用。
-- 只替换引用高亮和类型层级请求入口，不改全局 vim API、窗口、键位或实际 rename 流程。
-- 上游修复后，升级 plugins/lsp.lua 的提交并通过 tests/lsp.py，可移除对应补丁。
local M = {}

local function setup_rename()
	local namespace = vim.api.nvim_create_namespace("LspsagaRename")
	-- Saga 完成 rename 会清空实例字段，因此补丁安装在其方法表中。
	getmetatable(require("lspsaga.rename")).find_reference = function(self)
		local bufnr = vim.api.nvim_get_current_buf()
		local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
		-- 请求独占一个 token；取消、重新打开或编辑原文后，旧结果不能重新点亮已清除的高亮。
		local session = {}
		self.reference_session = session
		local client = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/references" })[1]
		if not client then
			return
		end

		local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
		params.context = { includeDeclaration = true }
		client:request("textDocument/references", params, function(err, locations)
			if
				err
				or not locations
				or self.reference_session ~= session
				or not vim.api.nvim_buf_is_valid(bufnr)
				or vim.api.nvim_buf_get_changedtick(bufnr) ~= changedtick
				or not self.winid
				or not vim.api.nvim_win_is_valid(self.winid)
				or vim.api.nvim_win_get_buf(self.winid) ~= self.bufnr
			then
				return
			end
			for _, location in ipairs(locations) do
				if location.range and vim.uri_to_bufnr(location.uri) == bufnr then
					local range = location.range
					local first = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, false)[1]
					local last = vim.api.nvim_buf_get_lines(bufnr, range["end"].line, range["end"].line + 1, false)[1]
					if first and last then
						-- LSP 的 UTF-16/UTF-8 字符偏移转为 extmark 字节偏移，避免中文或 emoji 后错位。
						local start_col = vim.str_byteindex(first, client.offset_encoding, range.start.character, false)
						local end_col = vim.str_byteindex(last, client.offset_encoding, range["end"].character, false)
						vim.api.nvim_buf_set_extmark(bufnr, namespace, range.start.line, start_col, {
							end_row = range["end"].line,
							end_col = end_col,
							hl_group = "RenameMatch",
							strict = false,
						})
					end
				end
			end
		end, bufnr)
	end
end

-- 保留 Saga 的多服务器/多结果选择，只为 prepareTypeHierarchy 显式提供服务器编码。
local function setup_typehierarchy()
	local hierarchy = require("lspsaga.typehierarchy")
	local util = require("lspsaga.util")
	local method = "textDocument/prepareTypeHierarchy"
	-- clean() 会清空实例字段，修复必须安装在方法表，才能跨窗口关闭继续生效。
	getmetatable(hierarchy).send_prepare_type = function(self)
		if self.pending_request then
			vim.notify("[lspsaga] a request has already been sent, please wait.")
			return
		end
		local bufnr = vim.api.nvim_get_current_buf()
		local clients = util.get_client_by_method(method)
		if #clients == 0 then
			vim.notify("[lspsaga] typehierarchy is not supported by the clients of the current buffer")
			return
		end

		local index = 1
		if #clients > 1 then
			local choices = { "Select client: " }
			for i, client in ipairs(clients) do
				choices[#choices + 1] = string.format("%d. %s", i, client.name)
			end
			index = vim.fn.inputlist(choices)
		end
		local client = clients[index]
		if not client then
			return
		end

		self.main_buf = bufnr
		self.list = require("lspsaga.slist").new()
		local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
		client:request(method, params, function(err, items)
			if err or not items or #items == 0 or vim.api.nvim_get_current_buf() ~= bufnr then
				return
			end
			local item_index = 1
			if #items > 1 then
				local choices = {}
				for i, item in ipairs(items) do
					choices[#choices + 1] = string.format("%d. %s", i, item.detail or item.name)
				end
				item_index = vim.fn.inputlist(choices)
			end
			-- 必须传选中的 LSP 对象；取消选择时直接结束，避免继续发送空请求。
			if items[item_index] then
				self:type_hierarchy(items[item_index], client)
			end
		end, bufnr)
	end
end

function M.setup()
	setup_rename()
	setup_typehierarchy()
end

return M
