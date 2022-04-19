----------------------------------------------------------------------
------------------------- LSP REQUIRE --------------------------------
----------------------------------------------------------------------
local lsp_modules = {
	"LSP.lsp-installer",
	"LSP.lspsaga",
	"LSP.lsp-color",
}
for _, mod in ipairs(lsp_modules) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while call LSP module: ", err)
	end
end
