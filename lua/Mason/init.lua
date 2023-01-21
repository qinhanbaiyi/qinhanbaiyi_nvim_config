----------------------------------------------------------------------
------------------------- Mason REQUIRE --------------------------------
----------------------------------------------------------------------

require("mason").setup()
local lsp_modules = {
	"Mason.mason-lsp",
	"Mason.format",
	"Mason.dap",
}
for _, mod in ipairs(lsp_modules) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while call LSP module: ", err)
	end
end
