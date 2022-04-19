-- require("plugins")
-- require("Telescope-config")
-- require("Treesitter")
-- require("ftplugin.init")
-- require("barbar-config")
-- require("keymappings-config")
-- require("LSP")
-- require("nvim-cmp")
-- require("nvim-autopair")
-- require("luasnip_snippets")
-- require("nvim-comment")
-- require("nvim-foldtext")
-- require("nvim-formatter")
-- require("nvim-glow-markdown")
-- require("nvim-null-ls")
-- require("nvim-prettier")
-- require("nvim-sniprun")
-- require("nvim-spellcheck")
-- require("nvim-symbols-outline")
-- require("nvim-toggleterm")
-- require("nvim_setting-config")
-- require("texmagic-config")
-- require("web-devicons-config")
-- require("Which-key-config")

local M = {
	"plugins",
	"Telescope-config",
	"Treesitter",
	"ftplugin.init",
	"barbar-config",
	"keymappings-config",
	"LSP",
	"nvim-cmp",
	"nvim-autopair",
	"luasnip_snippets",
	"nvim-comment",
	"nvim-foldtext",
	"nvim-formatter",
	"nvim-glow-markdown",
	"nvim-null-ls",
	"nvim-prettier",
	"nvim-sniprun",
	"nvim-spellcheck",
	"nvim-symbols-outline",
	"nvim-toggleterm",
	"nvim_setting-config",
	"texmagic-config",
	"web-devicons-config",
	"Which-key-config",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while calling init.lua:", err)
	end
end
