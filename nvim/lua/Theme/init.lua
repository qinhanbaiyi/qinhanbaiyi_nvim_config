local M = {
	"Theme.github",
	"Theme.barbar",
	"Theme.web-devicons",
	"Theme.symbols-outline",
	"Theme.indent",
	"Theme.lightline",
	"Theme.foldtext",
}

for _, mod in ipairs(M) do
	local ok, err = pcall(require, mod)
	if not ok then
		print("Err in calling theme: ", err)
	end
end
vim.cmd([[colorscheme github_dark]])
