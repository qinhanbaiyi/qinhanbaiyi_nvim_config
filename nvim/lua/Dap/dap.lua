local M = {}
M = {
	"Dap.lang.rust",
	"Dap.lang.python",
	"Dap.lang.cpp",
	"Dap.lang.r",
	"Dap.lang.lua",
	"Dap.lang.ui",
	"Dap.lang.config",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error in calling Debug: " .. err)
	end
end
