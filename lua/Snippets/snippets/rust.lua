local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")

local function rustdocsnip(args, _, old_state)
	local nodes = {
		t({ "/**", " * " }),
		i(1, "A short Description"),
		t({ "", "" }),
	}
	local param_nodes = {}
	if old_state then
		nodes[2] = i(1, old_state.descr:ger_text())
	end
	param_nodes.descr = nodes[2]

	-- At least one param
	if string.find(arg[2][1], ", ", true) then
		vim.list_extend(nodes, { t({ " * ", "" }) })
	end

	local insert = 2
	for _, arg in ipairs(vim.split(arg[2][1], ", ", true)) do
		-- get actual name parameter.
		arg = vim.split(arg, " ", true)[2]
		if arg then
			local inode
			if old_state and old_state[arg] then
				inode = i(insert, old_state["arg" .. arg]:ger_text())
			else
				inode = i(insert)
			end
			vim.list_extend(nodes, { t({ " * @param " .. arg .. " " }), t({ "", "" }) })
			param_nodes["arg" .. arg] = inode

			insert = insert + 1
		end
	end

	if vim.tbl_count(args[3]) ~= 1 then
		local exc = string.gsub(args[3][2], " throws ", "")
		local ins
		if old_state and old_state.ex then
			ins = i(insert, old_state.ex:get_text())
		else
			ins = i(insert)
		end
		vim.list_extend(nodes, { t({ " * ", " * @throws " .. exc .. " " }), ins, t({ "", "" }) })
		param_nodes.ex = ins
		insert = insert + 1
	end

	vim.list_extend(nodes, { t({ " */" }) })

	local snip = sn(nil, nodes)
	-- Error on attempting overwrite.
	snip.old_state = param_nodes
	return snip
end

local shortcut = function(val)
	if type(val) == "string" then
		return { t({ val }), i(0) }
	end

	if type(val) == "table" then
		for k, v in ipairs(val) do
			if type(v) == "string" then
				val[k] = t({ v })
			end
		end
	end

	return val
end

local rust = {
	s({ trig = "fn~", name = "fn~ &self", dscr = "** fn name(&self) **" }, {
		t("fn "),
		i(1, "name"),
		t("(&self, "),
		i(2, "param"),
		t(") "),
		c(3, {
			t(""),
			sn(nil, { t(" -> "), i(1) }),
		}),
		t({ " {", "\t" }),
		i(4, ""),
		t({ "\t", "}" }),
	}),
	s("modtest", {
		t({ "#[cfg(test)]", "" }),
		t({ "mod test {" }),
		t({ "", "" }),
		c(1, {
			t({ "    use super::*;" }),
			t({ "" }),
		}),
		t({ "", "" }),
		t("    "),
		i(2),
		t({ "\t", "}" }),
	}),
	s("test", {
		t({ "#[test]", "\t" }),
	}),
}
return rust
