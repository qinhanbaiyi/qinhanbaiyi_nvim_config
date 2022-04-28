local M = {}
M = {
	"Debug.rust",
	"Debug.python",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error in calling Rust debug: " .. err)
	end
end
