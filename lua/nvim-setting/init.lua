local M = {
	"nvim-setting.set",
	"nvim-setting.keymap",
	"nvim-setting.autocmd",
}
for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Error while call Nvim-setting module: ", err)
	end
end
