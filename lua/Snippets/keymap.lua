------------------------------------------------------------------------------------------------
------------------------------------ KEY MAPPING -----------------------------------------------
------------------------------------------------------------------------------------------------
local ls = require("luasnip")
-- <c-k> is my expansion key
-- this will expand the current item or jump to the next item within the snippet.
local keymap = vim.keymap.set
keymap({ "i", "s" }, "<c-k>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true, noremap = true })

-- <c-j> is my jump backwards key.
-- this always moves to the previous item within the snippet
keymap({ "i", "s" }, "<c-j>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true, noremap = true })

-- <c-l> is selecting within a list of options.
-- This is useful for choice nodes (introduced in the forthcoming episode 2)
keymap({ "i", "s" }, "<c-l>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	else
		vim.api.nvim_feedkeys(require("cmp.utils.keymap").t("<right>"), "n", true)
		-- vim.api.nvim_feedkeys("<right>", "i", true)
		-- vim.api.nvim_input({ "<right>" })
	end
end, { noremap = true, silent = true })

-- c()
keymap("i", "<c-u>", require("luasnip.extras.select_choice"), { silent = true, noremap = true })

-- shorcut to source my luasnips file again, which will reload my snippets
keymap(
	"n",
	"<leader><leader>s",
	"<cmd>source ~/.config/nvim/lua/luasnip_snippets/init.lua<CR>",
	{ silent = true, noremap = true }
)
