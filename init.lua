local M = {
	"plugins",
	"Telescope-config.init",
	"Treesitter",
	"nvim-setting",
	"Annotation",
	"CMP",
	"Snippets",
	"Term",
	"Which-key-config",
	"Theme",
	"LSP",
	"Mason",
	"Dap",
	"ftplugin.init",
	"Git",
	"Dev",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while calling init.lua:", err)
	end
end
