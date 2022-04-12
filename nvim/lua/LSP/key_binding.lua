-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "[d", ":Lspsaga diagnostic_jump_prev<CR>", opts)
vim.api.nvim_set_keymap("n", "]d", ":Lspsaga diagnostic_jump_next<CR>", opts)

-- local function on_attach(client, bufnr)
-- 	-- Set up buffer-local keymaps (vim.api.nvim_buf_set_keymap()), etc.
-- 	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
-- end
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local servers = { "rust_analyzer", "pylsp", "bashls", "vimls", "r_language_server" }
-- for _, lsp in pairs(servers) do
-- 	require("lspconfig")[lsp].setup({
-- 		on_attach = on_attach,
-- 		flags = {
-- 			-- This will be the default in neovim 0.7+
-- 			debounce_text_changes = 150,
-- 		},
-- 	})
-- end
-- -- float window of definition
-- local function preview_location_callback(_, result)
-- 	if result == nil or vim.tbl_isempty(result) then
-- 		return nil
-- 	end
-- 	vim.lsp.util.preview_location(result[1])
-- end
--
-- function PeekDefinition()
-- 	local params = vim.lsp.util.make_position_params()
-- 	return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
-- end
