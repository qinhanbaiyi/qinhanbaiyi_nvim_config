local M = {
	-- "plugins",
	"plugins.lazy",
	"Telescope",
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
	"Git",
	"Dev",
	"Text",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while calling init.lua:", err)
	end
end
