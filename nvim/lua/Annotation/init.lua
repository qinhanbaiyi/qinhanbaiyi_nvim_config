local M = {
	"Annotation.Neogen",
	"Annotation.comment",
}
for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while call Anno module: ", err)
	end
end
