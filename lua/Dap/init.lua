local M = {}
M = {
	"Dap.dap",
	"Dap.sniprun",
	"Dap.dap_visual",
	"Dap.refactoring",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error in calling Debug: " .. err)
	end
end
