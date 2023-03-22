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
-- @lspkind1
local types = require("cmp.types")
local str = require("cmp.utils.str")
local lspkind1 = {
	format = lspkind.cmp_format({
		menu = {
			buffer = "[Buffer]",
			luasnip = "[LuaSnip]",
			latex_symbols = "[Latex]",
			nvim_lsp = "[LSP]",
			nvim_lua = "[Lua]",
			cmp_tabnine = "[TN]",
			path = "[path]",
		},
		before = function(entry, vim_item)
			-- Get the full snippet (and only keep first line)
			local word = entry:get_insert_text()
			if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
				word = vim.lsp.util.parse_snippet(word)
			end
			word = str.oneline(word)

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
	-- fields = { "kind", "abbr", "menu" },
}

-- local lspkind = require("lspkind")
--
-- local source_mapping = {
--      buffer = "[Buffer]",
--      nvim_lsp = "[LSP]",
--      nvim_lua = "[Lua]",
--      cmp_tabnine = "[TN]",
--      path = "[path]",
-- }
--
-- require("cmp").setup({
--      formatting = {
--              format = function(entry, vim_item)
--                      -- if you have lspkind installed, you can use it like
--                      -- in the following line:
--                      vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })
--                      vim_item.menu = source_mapping[entry.source.name]
--                      if entry.source.name == "cmp_tabnine" then
--                              local detail = (entry.completion_item.data or {}).detail
--                              vim_item.kind = ""
--                              if detail and detail:find(".*%%.*") then
--                                      vim_item.kind = vim_item.kind .. " " .. detail
--                              end
--
--                              if (entry.completion_item.data or {}).multiline then
--                                      vim_item.kind = vim_item.kind .. " " .. "[ML]"
--                              end
--                      end
--                      local maxwidth = 80
--                      vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
--                      return vim_item
--              end,
--      },
-- })

-------------------------------------------------------------------------------
--------------------------------- TabNine -------------------------------------
-------------------------------------------------------------------------------
-- local tabnine = require("cmp_tabnine.config")
--
-- tabnine:setup({
--      max_lines = 1000,
--      max_num_results = 20,
--      sort = true,
--      run_on_every_keystroke = true,
--      snippet_placeholder = "..",
--      ignored_file_types = {
--              -- default is not to ignore
--              -- uncomment to ignore in lua:
--              -- lua = true
--      },
--      show_prediction_strength = false,
-- })

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
			-- behavior = cmp.ConfirmBehavior.Replace,
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
		{ name = "nvim_lsp", group_index = 1, priority = 80 },
		{ name = "luasnip", group_index = 1, priority = 80 },
		{
			name = "buffer",
			keyword_length = 4,
			option = {
				get_bufnrs = function()
					local bufs = {}
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						bufs[vim.api.nvim_win_get_buf(win)] = true
					end
					return vim.tbl_keys(bufs)
				end,
			},
			group_index = 1,
		},
		{ name = "nvim_lsp_signature_help", group_index = 1, priority = 80 },
		{ name = "path" },
		-- { name = "cmp_tabnine" },
		--{name = "calc"},
		--{name = "spell"},
		--{name = "emoji"}
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})
vim.cmd([[
" gray
highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
" blue
highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
highlight! link CmpItemAbbrMatchFuzzy CmpItemAbbrMatch
" light blue
highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
highlight! link CmpItemKindInterface CmpItemKindVariable
highlight! link CmpItemKindText CmpItemKindVariable
" pink
highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
highlight! link CmpItemKindMethod CmpItemKindFunction
" front
highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
highlight! link CmpItemKindProperty CmpItemKindKeyword
highlight! link CmpItemKindUnit CmpItemKindKeyword
]])

-------------------------------------------------------------------------------
------------------------------- EXTENSIONS ------------------------------------
-------------------------------------------------------------------------------

-- cmp_dictionary root dictionary file path
-- vim.opt.dictionary:append("D:\\Neovim\\share\\dict\\words.txt")

-- cmp_cmdline
cmp.setup.cmdline(":", {
	sources = {
		{ name = "cmdline" },
		{ name = "nvim_lsp", group_index = 1, priority = 80 },
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
			group_index = 1,
		},
		{ name = "path" },
		-- { name = "cmp_tabnine" },
		-- { name = "calc" },
		{ name = "otter" },
	},
})
-------------------------------------------------------------------------------
------------------------------- EXTENSIONS ------------------------------------
-------------------------------------------------------------------------------
