require("lspconfig").gopls.setup({
	on_attach = function(client)
		-- [[ other on_attach code ]]
		require("illuminate").on_attach(client)
	end,
})

local keymap = vim.keymap.set
local opt = { noremap = true, silent = true }
keymap("n", "<A-n>", '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', opt)
keymap("n", "<A-p>", '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', opt)
