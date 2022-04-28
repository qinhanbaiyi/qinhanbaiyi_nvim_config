local M = {
	"plugins",
	"Telescope-config",
	"Treesitter",
	"Neogen",
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
	"theme",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while calling init.lua:", err)
	end
end
