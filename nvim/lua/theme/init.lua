local M = {
	"theme.github",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Err in calling theme: ", err)
	end
end
