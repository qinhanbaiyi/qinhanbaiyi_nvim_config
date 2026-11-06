-- Lua 的 require、模块骨架与函数片段。参数注释由 helpers/lua.lua 读取当前函数生成。
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt
local lua_utils = require("snippets.helpers.lua")
local su = require("snippets.helpers.string")
local tl = su.box_trim_lines
local indentation = su.get_space_str(vim.opt.softtabstop:get())

return {
	-- 根据 require 路径的最后一段同步更新局部变量名。
	s("req", {
		t("local "),
		f(function(import_name)
			local parts = vim.split(import_name[1][1], ".", true)
			return parts[#parts] or ""
		end, { 1 }),
		t({ " = require('" }),
		i(1),
		t("')"),
	}),
	s(
		"M",
		fmt(
			tl([[
		local M = {{}}
		{}
		return M
		]]),
			{
				i(1),
			}
		)
	),
	s(
		"func",
		fmt(
			tl([[
		{}{}
		function {}({}) 
		{}{}
		end
		]]),
			{
				f(function(args)
					return "-- " .. args[1][1] .. " "
				end, { 1 }),
				-- 依赖参数节点 2，参数编辑后重新生成对应注释。
				d(4, lua_utils.get_current_func_doc_comment_snip, { 2 }),
				i(1),
				i(2),
				t(su.get_space_str(8)),
				i(3),
			}
		)
	),
	s(
		"localfunc",
		fmt(
			tl([[
                    -- {} {}{}
                    local {} = function({})
                        {}{}
                    end
                ]]),
			{
				rep(1),
				i(4),
				d(5, lua_utils.get_current_func_doc_comment_snip, { 2 }),
				i(1),
				i(2),
				t(indentation),
				i(3),
			}
		)
	),
}
