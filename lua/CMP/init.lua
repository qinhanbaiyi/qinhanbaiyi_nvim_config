local M = {
	"CMP.cmp",
	"CMP.spellcheck",
	"CMP.autopair",
	"CMP.copilot",
}
for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while call CMP module: ", err)
	end
end
