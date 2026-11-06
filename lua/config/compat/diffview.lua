-- Diffview 固定提交的面板配置和私有 Git 历史解析尚未迁移新版校验 API。
-- 仅将旧表式校验转换为逐字段 vim.validate，参数检查和后续插件逻辑保持原样。
-- 升级上游固定提交时必须重新核对；上游采用新版校验后移除本清单和 spec.init 注册。
return {
	revision = "4516612fe98ff56ae0415a259ff6361a89419b0a",
	modules = {
		{
			name = "diffview.ui.panel",
			path = "lua/diffview/ui/panel.lua",
			sha256 = "536a2f1a42cfc8fe19f2749793a08b7a59570b5eff14889c5383770dff593fad",
			replacements = {
				{
					before = [=[  local function valid_enum(arg, values, optional)
    return {
      arg,
      function(v) return (optional and v == nil) or vim.tbl_contains(values, v) end,
      table.concat(vim.tbl_map(function(v) return ([['%s']]):format(v) end, values), "|"),
    }
  end

  vim.validate({ type = valid_enum(config.type, { "split", "float" }) })

  if config.type == "split" then
    ---@cast config PanelSplitSpec
    self.state.form = vim.tbl_contains({ "top", "bottom" }, config.position) and "row" or "column"

    vim.validate({
      position = valid_enum(config.position, { "left", "top", "right", "bottom" }),
      relative = valid_enum(config.relative, { "editor", "win" }),
      width = { config.width, "number", true },
      height = { config.height, "number", true },
      win_opts = { config.win_opts, "table" }
    })
  else
    ---@cast config PanelFloatSpec
    local border = { "none", "single", "double", "rounded", "solid", "shadow" }

    vim.validate({
      relative = valid_enum(config.relative, { "editor", "win", "cursor" }),
      win = { config.win, "n", true },
      anchor = valid_enum(config.anchor, { "NW", "NE", "SW", "SE" }, true),
      width = { config.width, "n", false },
      height = { config.height, "n", false },
      row = { config.row, "n", false },
      col = { config.col, "n", false },
      zindex = { config.zindex, "n", true },
      style = valid_enum(config.style, { "minimal" }, true),
      win_opts = { config.win_opts, "table" },
      border = {
        config.border,
        function(v)
          if v == nil then return true end

          if type(v) == "table" then
            return #v >= 2
          end

          return vim.tbl_contains(border, v)
        end,
        ("%s or a list of length >=2"):format(
          table.concat(vim.tbl_map(function(v)
            return ([['%s']]):format(v)
          end, border), "|")
        )
      },
    })
  end
]=],
					after = [=[  local function validate_enum(name, value, values, optional)
    vim.validate(name, value, function(v)
      return (optional and v == nil) or vim.tbl_contains(values, v)
    end, false, table.concat(vim.tbl_map(function(v)
      return ([['%s']]):format(v)
    end, values), "|"))
  end

  validate_enum("type", config.type, { "split", "float" })
  if config.type == "split" then
    self.state.form = vim.tbl_contains({ "top", "bottom" }, config.position) and "row" or "column"
    validate_enum("position", config.position, { "left", "top", "right", "bottom" })
    validate_enum("relative", config.relative, { "editor", "win" })
    vim.validate("width", config.width, "number", true)
    vim.validate("height", config.height, "number", true)
    vim.validate("win_opts", config.win_opts, "table")
  else
    local border = { "none", "single", "double", "rounded", "solid", "shadow" }
    validate_enum("relative", config.relative, { "editor", "win", "cursor" })
    vim.validate("win", config.win, "number", true)
    validate_enum("anchor", config.anchor, { "NW", "NE", "SW", "SE" }, true)
    vim.validate("width", config.width, "number")
    vim.validate("height", config.height, "number")
    vim.validate("row", config.row, "number")
    vim.validate("col", config.col, "number")
    vim.validate("zindex", config.zindex, "number", true)
    validate_enum("style", config.style, { "minimal" }, true)
    vim.validate("win_opts", config.win_opts, "table")
    vim.validate("border", config.border, function(v)
      if v == nil then return true end
      if type(v) == "table" then return #v >= 2 end
      return vim.tbl_contains(border, v)
    end, false, ("%s or a list of length >=2"):format(
      table.concat(vim.tbl_map(function(v) return ([['%s']]):format(v) end, border), "|")
    ))
  end
]=],
				},
			},
		},
		{
			name = "diffview.vcs.adapters.git",
			path = "lua/diffview/vcs/adapters/git/init.lua",
			sha256 = "5d77fd042d1af44ee97570032fb4823a00809cc60d7e2e1a68a32b88ad20d26c",
			replacements = {
				{
					before = [=[  ret.valid = #namestat == #numstat and pcall(
    vim.validate,
    {
      left_hash = { ret.left_hash, "string", true },
      right_hash = { ret.right_hash, "string" },
      merge_hash = { ret.merge_hash, "string", true },
      author = { ret.author, "string" },
      time = { ret.time, "number" },
      time_offset = { ret.time_offset, "string" },
      rel_date = { ret.rel_date, "string" },
      ref_names = { ret.ref_names, "string" },
      reflog_selector = { ret.reflog_selector, "string" },
      subject = { ret.subject, "string" },
    }
  )]=],
					after = [=[  ret.valid = #namestat == #numstat and pcall(function()
    vim.validate("left_hash", ret.left_hash, "string", true)
    vim.validate("right_hash", ret.right_hash, "string")
    vim.validate("merge_hash", ret.merge_hash, "string", true)
    vim.validate("author", ret.author, "string")
    vim.validate("time", ret.time, "number")
    vim.validate("time_offset", ret.time_offset, "string")
    vim.validate("rel_date", ret.rel_date, "string")
    vim.validate("ref_names", ret.ref_names, "string")
    vim.validate("reflog_selector", ret.reflog_selector, "string")
    vim.validate("subject", ret.subject, "string")
  end)]=],
				},
			},
		},
	},
}
