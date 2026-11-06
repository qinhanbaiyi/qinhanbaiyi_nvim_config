-- Markdown 代码块、链接、表格与工作记录模板；此模块只提供片段定义。
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s("bash", {
		t({ "```bash", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("c", {
		t({ "```c", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("cpp", {
		t({ "```cpp", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("rust", {
		t({ "```rust", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("go", {
		t({ "```go", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("R", {
		t({ "```R", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("latex", {
		t({ "```latex", "" }),
		i(1),
		t({ "", "```" }),
	}),
	s("url", {
		t("["),
		i(1, "alias"),
		t("]"),
		t("("),
		i(2, "Url_link"),
		t(")"),
		i(0),
	}),
	s("ts", {
		t("- [ ] "),
		i(1),
		t({ "", "" }),
	}),
	s({ trig = "image", name = "markdown style", dscr = "markdown style" }, {
		t("!["),
		i(1, "alias"),
		t("]"),
		t("("),
		i(2, "Link or Path"),
		t(")"),
		i(0),
	}),
	s({ trig = "image", name = "html style", dscr = "html style" }, {
		t({ '<img src="' }),
		i(1, "Path or Url"),
		t({ '" alt="' }),
		i(2, "alias"),
		t('"'),
		c(3, {
			t(""),
			sn(1, {
				t(" width="),
				i(1, "number"),
				t(" height="),
				i(2, "number"),
			}),
		}),
		t(">"),
	}),
	s({ trig = "tb(%d+)*(%d+)", regTrig = true, dscr = "生成表格" }, {
		-- 行数和列数来自触发词捕获；额外插入一行 Markdown 表头分隔符。
		d(1, function(args, snip, old_state, initial_text)
			local nodes = {}
			-- 捕获值是匹配到的数字文本，沿用 Lua 的数字转换规则参与计算。
			local row = snip.captures[1]
			local col = snip.captures[2]
			-- 每行交错排列竖线和单元格节点，插入位置按行递增。
			for j = 1, row + 1 do
				for k = 1, col do
					local iNode
					if j == 2 then
						iNode = i((j - 1) * col + k, ":-:")
					else
						iNode = i((j - 1) * col + k, initial_text)
					end
					nodes[(col * 2 + 1) * (j - 1) + 2 * k] = iNode
					nodes[(col * 2 + 1) * (j - 1) + 2 * k - 1] = t("|")
				end
				-- 闭合当前行的最后一条竖线，再开始下一行。
				nodes[(col * 2 + 1) * (j - 1) + 2 * col + 1] = t({ "|", "" })
			end
			local snip = sn(nil, nodes)
			return snip
		end, {}, "   "),
	}),
	-- 通用任务清单沿用原触发词和 9 个跳转节点，避免把个人学习安排写进公共模板。
	s(
		"dailyWorkReport",
		fmt(
			[[
# 每日任务记录 {}

## 计划任务

- [ ] 重点任务：{}
- [ ] 常规任务：{}
- [ ] 待跟进事项：{}

## 完成情况

- 已完成事项：{}
- 问题与处理：{}

## 总结

- 今日记录：{}
- 后续改进：{}

## 下一步

- {}
		]],
			{
				i(1, "日期"),
				i(2, "任务内容"),
				i(3, "任务内容"),
				i(4, "待跟进内容"),
				i(5),
				i(6),
				i(7),
				i(8),
				i(9, "下一步计划"),
			}
		)
	),
}
