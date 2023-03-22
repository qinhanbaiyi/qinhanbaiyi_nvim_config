local M = {
	"Dev.lua_dev",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while call Dev module: ", err)
	end
end
