local M = {
	"plugins",
	"Telescope-config",
	"Treesitter",
	"nvim-setting",
	"LSP",
	"Annotation",
	"CMP",
	"Snippets",
	"Term",
	"Which-key-config",
	"Theme",
	"Dap",
	"ftplugin.init",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while calling init.lua:", err)
	end
end
