local M = {
	"Term.toggleterm",
}
for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while call Term module: ", err)
	end
end
