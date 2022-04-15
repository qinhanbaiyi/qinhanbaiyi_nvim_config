--                  __                       ____
--                 /\ \                     /\  _`\           __
--                 \ \ \      __  __     __ \ \,\L\_\    ___ /\_\  _____
--                  \ \ \  __/\ \/\ \  /'__`\\/_\__ \  /' _ `\/\ \/\ '__`\
--                   \ \ \L\ \ \ \_\ \/\ \L\.\_/\ \L\ \/\ \/\ \ \ \ \ \L\ \
--                    \ \____/\ \____/\ \__/.\_\ `\____\ \_\ \_\ \_\ \ ,__/
--                     \/___/  \/___/  \/__/\/_/\/_____/\/_/\/_/\/_/\ \ \/
--                                                                   \ \_\
--                                                                    \/_/

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local types = require("luasnip.util.types")

ls.config.set_config({
	-- This tells LuaSnip to remember to keep around the last snippet.
	-- You can jump back into it even if you move outside of the selection
	history = true,

	-- This one is cool cause if you have dynamic snippets, it updates as you type!
	updateevents = "TextChanged,TextChangedI",

	-- Autosnippets:
	enable_autosnippets = true,

	-- Crazy highlights!!
	-- #vid3
	-- ext_opts = nil,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { " <- Current Choice", "NonTest" } },
			},
		},
	},
})

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

local function rustdocsnip(args, _, old_state)
	local nodes = {
		t({ "/**", " * " }),
		i(1, "A short Description"),
		t({ "", "" }),
	}
	local param_nodes = {}
	if old_state then
		nodes[2] = i(1, old_state, descr:ger_text())
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
			vim.list_extend(nodes, { t({ " * @param " .. arg .. "" }), t({ "", "" }) })
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

local snippets = {}
-- `all` key means for all filetypes.
-- Shared between all filetypes. Has lower priority than a particular ft tho
snippets.all = {
	s("simple", {
		t({ "Wow, you were get right!" }),
	}),
	s("trigger", {
		i(1, "First jump"),
		t(" :: "),
		sn(2, {
			i(1, "Second jump"),
			t(" : "),
			i(2, "Third jump"),
		}),
	}),
	s({ trig = "data" }, {
		f(function()
			return string.format(string.gsub(vim.bo.commentstring, "%%s", "%%s"), os.date())
		end, {}),
	}),
	s("for", {
		t("for "),
		i(1, "k,v"),
		t(" in "),
		i(2, "ipairs()"),
		t({ "do", " " }),
		t("end"),
	}),
}
snippets.rust = {
	s({ trig = "fn~", name = "fn~ &self", dscr = "** fn name(&self) **" }, {
		t("fn "),
		i(1, "name"),
		t("(&self, "),
		i(2, "param"),
		t(") "),
		c(3, {
			t(""),
			sn(1, { t(" -> "), i(1) }),
		}),
		t({ "{", "\t" }),
		i(4, ""),
		t({ "\t", "}" }),
	}),
	s("cfg", {
		t({ "#[cfg(test)]", "\t" }),
		t("mod "),
		i(1, "module"),
		t({ "{", "\t" }),
		i(2),
		t({ "\t", "}" }),
	}),
	s("test", {
		t({ "#[test]", "\t" }),
	}),
	-- s("fndoc", {
	-- 	d(6, rustdocsnip, { 2, 4, 5 }),
	-- 	t({ "", "" }),
	-- 	c(1, {
	-- 		t(""),
	-- 		t("pub "),
	-- 	}),
	-- 	t("fn "),
	-- 	i(2, "name"),
	-- 	c(3, t({ "(" }), t({ "(&self, " })),
	-- 	i(4, "param"),
	-- 	t(") "),
	-- 	c(5, {
	-- 		t(""),
	-- 		i("->"),
	-- 	}),
	-- 	t({ "{", "\t" }),
	-- 	i(6, ""),
	-- 	t({ "\t", "}" }),
	-- }, {
	-- 	key = "rust",
	-- }),
}
ls.add_snippets("all", snippets.all, { key = "all" })
ls.add_snippets("rust", snippets.rust, { key = "rust" })
-- ls.snippets = snippets

------------------------------------------------------------------------------------------------
------------------------------------ KEY MAPPING -----------------------------------------------
------------------------------------------------------------------------------------------------

-- <c-k> is my expansion key
-- this will expand the current item or jump to the next item within the snippet.
local keymap = vim.keymap.set
keymap({ "i", "s" }, "<c-k>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })

-- <c-j> is my jump backwards key.
-- this always moves to the previous item within the snippet
keymap({ "i", "s" }, "<c-j>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true })

-- <c-l> is selecting within a list of options.
-- This is useful for choice nodes (introduced in the forthcoming episode 2)
keymap("i", "<c-i>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)

keymap("i", "<c-u>", require("luasnip.extras.select_choice"))

-- shorcut to source my luasnips file again, which will reload my snippets
keymap("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/luasnip_snippets/init.lua<CR>")
