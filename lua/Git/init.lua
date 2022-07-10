local M = {
	"Git.gitsigns",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error in calling Git: " .. err)
	end
end
