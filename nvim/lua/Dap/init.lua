local M = {}
M = {
	"Dap.sniprun",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		error("Error in calling Dap modual: ", err)
	end
end
