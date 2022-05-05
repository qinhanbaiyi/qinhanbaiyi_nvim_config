-------------------------------------------------------------------------------
------------------------------ RUNTIME-PATH -----------------------------------
-------------------------------------------------------------------------------
-- lua Language server protocol
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
-------------------------------------------------------------------------------
--------------------------- FORMAT AND SETTING --------------------------------
-------------------------------------------------------------------------------

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"
-- luasnip setup
-- local luasnip = require("luasnip")
local lspkind = require("lspkind")

-- nvim-cmp setup
local cmp = require("cmp")

-- 自动提示1 详情信息
-- @cmpFormat2
-- local cmpFormat1 = {
-- 	formatting = function(entry, vim_item)
-- 		-- fancy icons and a name of kind
-- 		vim_item.kind = lspkind.presets.default[vim_item.kind] .. " " .. vim_item.kind
-- 		-- set a name for each source
-- 		vim_item.menu = ({
-- 			buffer = "[Buffer]",
-- 			nvim_lsp = "[LSP]",
-- 			luasnip = "[LuaSnip]",
-- 			nvim_lua = "[Lua]",
-- 			cmp_tabnine = "[TabNine]",
-- 			look = "[Look]",
-- 			path = "[Path]",
-- 			spell = "[Spell]",
-- 			calc = "[Calc]",
-- 			emoji = "[Emoji]",
-- 			cmdline = "[CMDLINE]",
-- 			dictionary = "[DICT]",
-- 		})[entry.source.name]
-- 		return vim_item
-- 	end,
-- }

-- local cmp_kinds = kind_icons

-- @cmpFormat2
-- local cmpFormat2 = {
-- 	formatting = function(_, vim_item)
-- 		vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
-- 		return vim_item
-- 	end,
-- }

-- -- @cmpFormat3
-- local cmpFormat3 = {
-- 	formatting = function(entry, vim_item)
-- 		local kind_icons = {
-- 			Text = "",
-- 			Method = "",
-- 			Function = "",
-- 			Constructor = "",
-- 			Field = "ﰠ",
-- 			Variable = "",
-- 			Class = "ﴯ",
-- 			Interface = "",
-- 			Module = "",
-- 			Property = "ﰠ",
-- 			Value = "",
-- 			Enum = "",
-- 			Keyword = "",
-- 			Snippet = "",
-- 			Color = "",
-- 			File = "",
-- 			Reference = "",
-- 			Folder = "",
-- 			EnumMember = "",
-- 			Constant = "",
-- 			Struct = "פּ",
-- 			Event = "",
-- 			Operator = "",
-- 			TypeParameter = "",
-- 		}
-- 		-- Kind icons: concatenates icons
-- 		vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
-- 		-- Source
-- 		vim_item.menu = ({
-- 			buffer = "[Buffer]",
-- 			nvim_lsp = "[LSP]",
-- 			luasnip = "[LuaSnip]",
-- 			nvim_lua = "[Lua]",
-- 			cmp_tabnine = "[TabNine]",
-- 			look = "[Look]",
-- 			path = "[Path]",
-- 			spell = "[Spell]",
-- 			calc = "[Calc]",
-- 			emoji = "[Emoji]",
-- 			cmdline = "[CMDLINE]",
-- 			dictionary = "[DICT]",
-- 			latex_symbols = "[LaTeX]",
-- 		})[entry.source.name]
-- 		return vim_item
-- 	end,
-- }

-- @lspkind1
local types = require("cmp.types")
local str = require("cmp.utils.str")
local lspkind1 = {
	format = lspkind.cmp_format({
		before = function(entry, vim_item)
			-- Get the full snippet (and only keep first line)
			local word = entry:get_insert_text()
			if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
				word = vim.lsp.util.parse_snippet(word)
			end
			word = str.oneline(word)

			-- concatenates the string
			-- local max = 50
			-- if string.len(word) >= max then
			-- 	local before = string.sub(word, 1, math.floor((max - 3) / 2))
			-- 	word = before .. "..."
			-- end

			if
				entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet
				and string.sub(vim_item.abbr, -1, -1) == "~"
			then
				word = word .. "~"
			end
			vim_item.abbr = word

			return vim_item
		end,
	}),
}

------修复2021年10月12日 nvim-cmp.luaattempt to index field 'menu' (a nil value)---------
--重写插件方法,为了实现function 后,自动追加()
local keymap = require("cmp.utils.keymap")
cmp.confirm = function(option)
	option = option or {}
	local e = cmp.core.view:get_selected_entry() or (option.select and cmp.core.view:get_first_entry() or nil)
	if e then
		cmp.core:confirm(e, {
			behavior = option.behavior,
		}, function()
			local myContext = cmp.core:get_context({ reason = cmp.ContextReason.TriggerOnly })
			cmp.core:complete(myContext)
			--function() 自动增加()
			if
				e
				and e.resolved_completion_item
				and (e.resolved_completion_item.kind == 3 or e.resolved_completion_item.kind == 2)
			then
				vim.api.nvim_feedkeys(keymap.t("()<Left>"), "n", true)
			end
		end)
		return true
	else
		if vim.fn.complete_info({ "selected" }).selected ~= -1 then
			keymap.feedkeys(keymap.t("<C-y>"), "n")
			return true
		end
		return false
	end
end

-------------------------------------------------------------------------------
--------------------------------- SETTING -------------------------------------
-------------------------------------------------------------------------------

cmp.setup({
	formatting = lspkind1,
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		}),
		["<Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end,
		["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
	},
	sources = {
		{ name = "nvim_lsp", group_index = 1, priority = 1 },
		{ name = "luasnip", group_index = 1, priority = 1 },
		{
			name = "buffer",
			keyword_length = 2,
			option = {
				get_bufnrs = function()
					local bufs = {}
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						bufs[vim.api.nvim_win_get_buf(win)] = true
					end
					return vim.tbl_keys(bufs)
				end,
			},
			group_index = 2,
		},
		{ name = "path" },
		--{name = "cmp_tabnine"},
		--{name = "calc"},
		--{name = "spell"},
		--{name = "emoji"}
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})

-------------------------------------------------------------------------------
------------------------------- EXTENSIONS ------------------------------------
-------------------------------------------------------------------------------

-- cmp_dictionary root dictionary file path
-- vim.opt.dictionary:append("D:\\Neovim\\share\\dict\\words.txt")

-- cmp_cmdline
cmp.setup.cmdline(":", {
	sources = {
		{ name = "cmdline" },
		{ name = "path" },
	},
})

-------------------------------------------------------------------------------
------------------------------- EXTENSIONS ------------------------------------
-------------------------------------------------------------------------------

-- require('Comment.utils').ctype.{line,block}
--
-- require('Comment.utils').cmode.{toggle,comment,uncomment}
--
-- require('Comment.utils').cmotion.{line,char,v,V}
