-- 为未修复新版 Neovim 校验 API 的固定插件源码注册局部内存补丁。
-- 只替换清单列出的模块；插件 checkout、_G.vim、vim.validate 与警告处理均保持原样。
-- 每个模块先核对完整 SHA256，再要求每段旧代码唯一匹配；上游变化时明确报错。
local M = {}
local registered = {}

local function fail(name, reason)
	error(
		("插件兼容补丁 %s 失败：%s。请核对固定提交和 config/compat 清单。"):format(name, reason),
		0
	)
end

---@param source string 原模块的完整源码
---@param patch table 带 name、sha256、replacements 的固定源码清单
---@return string source 完成全部等价替换的源码
function M.transform(source, patch)
	if vim.fn.sha256(source) ~= patch.sha256 then
		fail(patch.name, "原文件 SHA256 不匹配，拒绝对未知版本应用补丁")
	end
	for index, replacement in ipairs(patch.replacements) do
		local first, last = source:find(replacement.before, 1, true)
		if not first or source:find(replacement.before, last + 1, true) then
			fail(patch.name, ("第 %d 段旧代码不是唯一匹配"):format(index))
		end
		source = source:sub(1, first - 1) .. replacement.after .. source:sub(last + 1)
	end
	return source
end

---@param plugin table Lazy 的插件记录，使用 dir 和固定 commit
---@param plan table config/compat 中的 revision 与 modules 清单
function M.register(plugin, plan)
	if plugin.commit ~= plan.revision then
		fail(plugin.name or plugin.dir, "插件声明未固定到补丁对应的提交")
	end
	for _, patch in ipairs(plan.modules) do
		local path = plugin.dir .. "/" .. patch.path
		local previous = registered[patch.name]
		if previous then
			-- 同一 init 可重复调用；禁止另一份清单覆盖已经注册的模块。
			if previous.path ~= path or not vim.deep_equal(previous.patch, patch) then
				fail(patch.name, "该模块已注册不同的补丁")
			end
		else
			if package.loaded[patch.name] or package.preload[patch.name] then
				fail(patch.name, "模块已加载或已有 preload，补丁必须在插件 init 阶段注册")
			end
			registered[patch.name] = { path = path, patch = vim.deepcopy(patch) }
			package.preload[patch.name] = function(...)
				local file, err = io.open(path, "rb")
				if not file then
					fail(patch.name, "读取原文件失败：" .. tostring(err))
				end
				local source = file:read("*a")
				file:close()
				source = M.transform(source, patch)
				-- 保留原文件路径，使插件异常的 traceback 仍可定位到上游模块。
				local chunk, compile_error = loadstring(source, "@" .. path)
				if not chunk then
					fail(patch.name, "补丁源码无法编译：" .. tostring(compile_error))
				end
				return chunk(...)
			end
		end
	end
end

return M
