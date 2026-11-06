-- ToggleTerm 当前固定提交尚有五处旧式校验，覆盖 ToggleTerm / TermExec / 发送选区入口。
-- 仅将旧表式校验转换为逐字段 vim.validate，参数检查和后续插件逻辑保持原样。
-- 升级上游固定提交时必须重新核对；上游采用新版校验后移除本清单和 spec.init 注册。
return {
	revision = "066cccf48a43553a80a210eb3be89a15d789d6e6",
	modules = {
		{
			name = "toggleterm",
			path = "lua/toggleterm.lua",
			sha256 = "1c93d2943dcbcc3bb2c341a6ce9f77b36e1263d1f6f17b79f2f02f1121b81590",
			replacements = {
				{
					before = [=[  vim.validate({ args = { args, "string" } })]=],
					after = [=[  vim.validate("args", args, "string")]=],
				},
				{
					before = [=[  vim.validate({
    cmd = { parsed.cmd, "string" },
    size = { parsed.size, "number", true },
    dir = { parsed.dir, "string", true },
    direction = { parsed.direction, "string", true },
    name = { parsed.name, "string", true },
    go_back = { parsed.go_back, "boolean", true },
    open = { parsed.open, "boolean", true },
  })]=],
					after = [=[  vim.validate("cmd", parsed.cmd, "string")
  vim.validate("size", parsed.size, "number", true)
  vim.validate("dir", parsed.dir, "string", true)
  vim.validate("direction", parsed.direction, "string", true)
  vim.validate("name", parsed.name, "string", true)
  vim.validate("go_back", parsed.go_back, "boolean", true)
  vim.validate("open", parsed.open, "boolean", true)]=],
				},
				{
					before = [=[  vim.validate({
    cmd = { cmd, "string" },
    num = { num, "number", true },
    size = { size, "number", true },
    dir = { dir, "string", true },
    direction = { direction, "string", true },
    name = { name, "string", true },
    go_back = { go_back, "boolean", true },
    open = { open, "boolean", true },
  })]=],
					after = [=[  vim.validate("cmd", cmd, "string")
  vim.validate("num", num, "number", true)
  vim.validate("size", size, "number", true)
  vim.validate("dir", dir, "string", true)
  vim.validate("direction", direction, "string", true)
  vim.validate("name", name, "string", true)
  vim.validate("go_back", go_back, "boolean", true)
  vim.validate("open", open, "boolean", true)]=],
				},
				{
					before = [=[  vim.validate({
    selection_type = { selection_type, "string", true },
    trim_spaces = { trim_spaces, "boolean", true },
    terminal_id = { id, "number", true },
  })]=],
					after = [=[  vim.validate("selection_type", selection_type, "string", true)
  vim.validate("trim_spaces", trim_spaces, "boolean", true)
  vim.validate("terminal_id", id, "number", true)]=],
				},
				{
					before = [=[  vim.validate({
    size = { parsed.size, "number", true },
    dir = { parsed.dir, "string", true },
    direction = { parsed.direction, "string", true },
    name = { parsed.name, "string", true },
  })]=],
					after = [=[  vim.validate("size", parsed.size, "number", true)
  vim.validate("dir", parsed.dir, "string", true)
  vim.validate("direction", parsed.direction, "string", true)
  vim.validate("name", parsed.name, "string", true)]=],
				},
			},
		},
	},
}
